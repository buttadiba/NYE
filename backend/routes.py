import email

from flask import Blueprint, Flask, request, jsonify 
from models import db, User, bcrypt, Role 
import jwt 
import datetime 
import uuid 
import mysql.connector


routes = Blueprint('routes', __name__)

# ======================
# CONNECTION DB
# ======================
import mysql.connector

def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="root",
        password="",
        database="nye_bd"
    )


SECRET_KEY = "mon_secret_pour_jwt"  #
# ===== LOGIN =====
@routes.route('/login', methods=['POST'])
def login():
        data = request.json
        email = data.get('email')
        password = data.get('password')

        if not email or not password:
            return jsonify({"error": "Email et mot de passe requis"}), 400

        user = User.query.filter_by(email=email).first()

        if not user:
            return jsonify({"error": "Utilisateur non trouvé"}), 404

        if not bcrypt.check_password_hash(user.password, password):
            return jsonify({"error": "Mot de passe incorrect"}), 401

        token = jwt.encode({
            'user_id': str(user.id),
            'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=24)
        }, SECRET_KEY, algorithm='HS256')

        return jsonify({
            "message": "Connexion réussie",
            "token": token,
            "user": {
                "id": str(user.id),
                "name": user.name,
                "email": user.email,
                "role": user.role.name
            }
        })


    # ===== REGISTER =====
@routes.route('/register', methods=['POST'])
def register():
        try:
            data = request.get_json()
            name = data.get('name')
            email = data.get('email')
            password = data.get('password')

            if not name or not email or not password:
                return jsonify({"error": "Champs manquants"}), 400

            hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

            role = Role.query.filter_by(name="USER").first()

            new_user = User(
                id=uuid.uuid4().hex,
                name=name,
                email=email,
                password=hashed_password,
                role_id=role.id
            )

            conn = get_db()
            cursor = conn.cursor()

            cursor.execute("""
                INSERT INTO users (id, name, email, password, role_id)
                VALUES (%s, %s, %s, %s, %s)
            """, (
                uuid.uuid4().hex,
                name,
                email,
                hashed_password,
                role.id
            ))

            conn.commit()
            cursor.close()
            conn.close() 

            return jsonify({"message": "Utilisateur enregistré avec succès"}), 201

        except Exception as e:
            return jsonify({"error": str(e)}), 500

# ======================
# TITLE FORMATTER
# ======================
def map_alert_title(alert_type):
    alert_type = (alert_type or "").lower()

    if "intrusion" in alert_type:
        return "Intrusion détectée 🚨"
    elif "mouvement" in alert_type:
        return "Mouvement suspect détecté"
    elif "camera" in alert_type:
        return "Caméra déclenchée"
    elif "urgence" in alert_type:
        return "Alerte d'urgence"
    else:
        return "Alerte système"


# ======================
# GET ALERTS (JOIN PROPRE)
# ======================
@routes.route('/alerts', methods=['GET'])
def get_alerts():
    conn = get_db()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("""
            SELECT 
                id,
                type,
                title,
                description,
                status,
                photo,
                created_at
            FROM alerts
            ORDER BY created_at DESC
        """)

        rows = cursor.fetchall()

        alerts = []

        for row in rows:
            alerts.append({
                "alert_id": row["id"],
                "title": map_alert_title(row["type"]),
                "subtitle": row["title"],
                "description": row["description"] or "",
                "status": row["status"] or "En attente",
                "photo": row["photo"] or "",
                "time": row["created_at"].strftime("%H:%M") if row["created_at"] else ""
            })

        return jsonify(alerts), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        conn.close()

    


# ======================
# ADD ALERT (TEST MANUEL)
# ======================
@routes.route('/add-alert', methods=['POST'])
def add_alert():
    try:
        data = request.json

        conn = get_db()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO alerts (type, title, description, status, created_at)
            VALUES (%s, %s, %s, %s, NOW())
        """, (
            data.get("type", "intrusion"),
            "Alerte ESP",   # obligatoire
            data.get("description", "test"),
            "En attente"
        ))

    

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({"message": "Alerte ajoutée"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500

    

app = Flask(__name__)
@routes.route('/alerts/<int:id>', methods=['PUT'])
def update_alert(id):
    try:
        data = request.get_json()
        new_status = data.get('status')

        conn = get_db()
        cursor = conn.cursor()

        # vérifier si existe
        cursor.execute("SELECT * FROM alerts WHERE id = %s", (id,))
        alert = cursor.fetchone()

        if not alert:
            return jsonify({"error": "Alerte non trouvée"}), 404

        # update status
        cursor.execute(
            "UPDATE alerts SET status = %s WHERE id = %s",
            (new_status, id)
        )

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"message": "Statut mis à jour"}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
# ======================
# LINK ALERT -> EMERGENCY (TEST)
# ======================
@routes.route('/link-alert', methods=['POST'])
def link_alert():
    try:
        data = request.json

        conn = get_db()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO alert_emergency (alert_id, emergency_id, contacted_at)
            VALUES (%s, %s, NOW())
        """, (
            data["alert_id"],
            data["emergency_id"]
        ))

        conn.commit()

        cursor.close()
        conn.close()

        return jsonify({"message": "Lien alert/emergency créé"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
import time
import os

@routes.route('/upload-image', methods=['POST'])
def upload_image():
    try:
        file = request.data

        filename = f"image_{int(time.time())}.jpg"
        filepath = os.path.join("uploads", filename)

        with open(filepath, "wb") as f:
            f.write(file)

        # 🔥 IMPORTANT : ajouter dans la base
        conn = get_db()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO alerts (type, title, description, status, photo, created_at)
            VALUES (%s, %s, %s, %s, %s, NOW())
        """, (
            "camera",
            "Photo capturée",
            "Image envoyée par ESP32",
            "En attente",
            filename
        ))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"message": "Image reçue", "filename": filename}), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500
from flask import Blueprint, request, jsonify 
from models import db, User, bcrypt, Role 
import jwt 
import datetime 
import uuid 
import mysql.connector

routes = Blueprint('routes', __name__)

# ======================
# CONNECTION DB
# ======================
db = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="nye_bd"
)

cursor = db.cursor(dictionary=True)
SECRET_KEY = "mon_secret_pour_jwt"  # 🔥 à changer en production
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

            db.commit()

            return jsonify({
                "message": "Utilisateur créé",
                "user": {
                    "email": new_user.email,
                    "name": new_user.name
                }
            }), 201

        except Exception as e:
            print("🔥 ERREUR FLASK:", str(e))
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
                "title": map_alert_title(row["type"]),  # 🔥 IMPORTANT
                "subtitle": row["title"],  # optionnel
                "description": row["description"] or "",
                "status": row["status"] or "En attente",
                "photo": row["photo"] or "",
                "time": row["created_at"].strftime("%H:%M") if row["created_at"] else ""
            })

        return jsonify(alerts), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ======================
# ADD ALERT (TEST MANUEL)
# ======================
@routes.route('/add-alert', methods=['POST'])
def add_alert():
    try:
        data = request.json

        cursor.execute("""
            INSERT INTO alerts (device_id, alert_type, description, status, created_at)
            VALUES (%s, %s, %s, %s, NOW())
        """, (
            1,
            data.get("type", "intrusion detectee"),
            data.get("description", "test"),
            "En attente"
        ))

        db.commit()

        return jsonify({"message": "Alerte ajoutée"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ======================
# LINK ALERT -> EMERGENCY (TEST)
# ======================
@routes.route('/link-alert', methods=['POST'])
def link_alert():
    try:
        data = request.json

        cursor.execute("""
            INSERT INTO alert_emergency (alert_id, emergency_id, contacted_at)
            VALUES (%s, %s, NOW())
        """, (
            data["alert_id"],
            data["emergency_id"]
        ))

        db.commit()

        return jsonify({"message": "Lien alert/emergency créé"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 500
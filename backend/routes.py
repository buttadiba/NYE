from flask import Blueprint, request, jsonify
from models import db, User, bcrypt, Role
import jwt
import datetime
import uuid

routes = Blueprint('routes', __name__)

SECRET_KEY = "mon_secret_pour_jwt"  # à changer pour la prod

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
    data = request.json
    name = data.get('name')
    email = data.get('email')
    password = data.get('password')
    role_name = data.get('role', 'USER')

    if not name or not email or not password:
        return jsonify({"error": "Nom, email et mot de passe requis"}), 400

    if User.query.filter_by(email=email).first():
        return jsonify({"error": "Email déjà utilisé"}), 409

    hashed_password = bcrypt.generate_password_hash(password).decode('utf-8')

    role = Role.query.filter_by(name=role_name).first()
    if not role:
        return jsonify({"error": f"Rôle {role_name} non trouvé"}), 400

    new_user = User(
        id=uuid.uuid4().hex,
        name=name,
        email=email,
        password=hashed_password,
        role_id=role.id
    )

    try:
        db.session.add(new_user)
        db.session.commit()
    except Exception as e:
        db.session.rollback()
        return jsonify({"error": str(e)}), 500

    return jsonify({
        "message": "Utilisateur créé avec succès",
        "user": {
            "id": new_user.id,
            "name": new_user.name,
            "email": new_user.email,
            "role": role.name
        }
    }), 201
from flask_sqlalchemy import SQLAlchemy
from flask_bcrypt import Bcrypt
import uuid

db = SQLAlchemy()
bcrypt = Bcrypt()

# ===== ROLE =====
class Role(db.Model):
<<<<<<< HEAD
    __tablename__ = 'role'
=======
    __tablename__ = 'roles'
>>>>>>> b0c0c1f50e88b73fc3d29c8411c00a205be0ef7f
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(50), unique=True, nullable=False)
# ===== USER =====
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.String(32), primary_key=True, default=lambda: uuid.uuid4().hex)
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
<<<<<<< HEAD
    role_id = db.Column(db.Integer, db.ForeignKey('role.id'), nullable=False)
=======
    role_id = db.Column(db.Integer, db.ForeignKey('roles.id'), nullable=False)
>>>>>>> b0c0c1f50e88b73fc3d29c8411c00a205be0ef7f

    role = db.relationship("Role")
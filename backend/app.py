from flask import Flask
from models import db, bcrypt  
from routes import routes      
import logging
from flask import send_from_directory
import os

logging.basicConfig(level=logging.DEBUG)
app = Flask(__name__)

# 🔹 Configuration base de données
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:@localhost/nye_bd'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# 🔹 Initialisation DB et bcrypt
db.init_app(app)
bcrypt.init_app(app)

# 🔹 Enregistrer les routes
app.register_blueprint(routes)  # il permet à Flask de connaître /login et /register

# 🔹 Route de test
@app.route('/')
def home():
    return "Backend NYE actif !"

UPLOAD_FOLDER = "uploads"

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@app.route('/uploads/<filename>')
def uploaded_file(filename):
    return send_from_directory(UPLOAD_FOLDER, filename)

# 🔹 Accès depuis le téléphone
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)
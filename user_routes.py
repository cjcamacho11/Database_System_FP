import pyodbc
from flask import Blueprint, jsonify, request
from config import DB_CONFIG  

api = Blueprint('api', __name__)  

def get_db_connection():
    return pyodbc.connect(
        f"DRIVER={{{DB_CONFIG['DRIVER']}}};SERVER={DB_CONFIG['SERVER']};"
        f"DATABASE={DB_CONFIG['DATABASE']};UID={DB_CONFIG['UID']};PWD={DB_CONFIG['PWD']}"
    )

# GET: Fetch all users
@api.route("/users", methods=["GET"])
def get_users():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Users")
        users = cursor.fetchall()
        conn.close()

        return jsonify([{"user_id": user[0], "username": user[1], "email": user[2]} for user in users])
    except Exception as e:
        return jsonify({"error": f"Database connection error: {e}"}), 500

# POST: Add a new user
@api.route("/users", methods=["POST"])
def create_user():
    data = request.get_json()

    # Check if user_id is provided in the request body
    if "user_id" not in data:
        return jsonify({"error": "user_id is required"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO Users (user_id, username, email, password, profile_picture, bio, permission) "
            "VALUES (?, ?, ?, ?, ?, ?, ?)",
            (data["user_id"], data["username"], data["email"], data["password"], 
             data.get("profile_picture"), data.get("bio"), data.get("permission", "user"))
        )
        conn.commit()
        conn.close()

        return jsonify({"message": "User added successfully"}), 201
    except Exception as e:
        return jsonify({"error": f"Failed to add user: {e}"}), 500

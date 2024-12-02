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


# PUT: Update a user
@api.route("/users/<int:user_id>", methods=["PUT"])
def update_user(user_id):
    data = request.get_json()
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE Users SET username = ?, email = ? WHERE user_id = ?",
            (data["username"], data["email"], user_id)
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "User updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Failed to update user: {e}"}), 500

# DELETE: Remove a user
@api.route("/users/<int:user_id>", methods=["DELETE"])
def delete_user(user_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Delete related records in Likes table
        cursor.execute("DELETE FROM Likes WHERE user_id = ?", user_id)

        # Delete related records in Follows table
        cursor.execute("DELETE FROM Follows WHERE follower_id = ? OR followed_id = ?", user_id, user_id)

        # Delete related records in Activity_Feed table
        cursor.execute("DELETE FROM Activity_Feed WHERE user_id = ?", user_id)

        # Delete related records in Playlist_Songs table
        cursor.execute("DELETE FROM Playlist_Songs WHERE playlist_id IN (SELECT playlist_id FROM Playlists WHERE user_id = ?)", user_id)

        # Delete related records in Playlists table
        cursor.execute("DELETE FROM Playlists WHERE user_id = ?", user_id)

        # Delete related records in Comments table
        cursor.execute("DELETE FROM Comments WHERE user_id = ?", user_id)

        # Delete related records in Notifications table
        cursor.execute("DELETE FROM Notifications WHERE user_id = ?", user_id)

        # Delete related records in Reports table
        cursor.execute("DELETE FROM Reports WHERE user_id = ?", user_id)

        # Now delete the user from the Users table
        cursor.execute("DELETE FROM Users WHERE user_id = ?", user_id)

        conn.commit()
        conn.close()

        return jsonify({"message": "User and related records deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Failed to delete user: {e}"}), 500

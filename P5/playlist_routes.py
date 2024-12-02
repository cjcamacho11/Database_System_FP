import pyodbc
from flask import Blueprint, jsonify, request
from config import DB_CONFIG

# Create a Blueprint for playlist-related routes
playlist_routes = Blueprint('playlist_routes', __name__)

# Helper function to get database connection
def get_db_connection():
    return pyodbc.connect(
        f"DRIVER={{{DB_CONFIG['DRIVER']}}};SERVER={DB_CONFIG['SERVER']};"
        f"DATABASE={DB_CONFIG['DATABASE']};UID={DB_CONFIG['UID']};PWD={DB_CONFIG['PWD']}"
    )

# GET: Fetch all playlists
@playlist_routes.route("/playlists", methods=["GET"])
def get_playlists():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Playlists")
        playlists = cursor.fetchall()
        conn.close()

        return jsonify([
            {
                "playlist_id": row[0],
                "user_id": row[1],
                "name": row[2],
                "is_public": row[3],
                "created_at": row[4],
                "updated_at": row[5]
            } for row in playlists
        ])
    except Exception as e:
        return jsonify({"error": f"Failed to fetch playlists: {e}"}), 500

# POST: Add a new playlist
@playlist_routes.route("/playlists", methods=["POST"])
def create_playlist():
    data = request.get_json()
    if "user_id" not in data or "name" not in data:
        return jsonify({"error": "user_id and name are required fields"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO Playlists (user_id, name, is_public) VALUES (?, ?, ?)",
            (data["user_id"], data["name"], data.get("is_public", "TRUE"))
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "Playlist created successfully"}), 201
    except Exception as e:
        return jsonify({"error": f"Failed to create playlist: {e}"}), 500

# PUT: Update an existing playlist
@playlist_routes.route("/playlists/<int:playlist_id>", methods=["PUT"])
def update_playlist(playlist_id):
    data = request.get_json()
    if "name" not in data and "is_public" not in data:
        return jsonify({"error": "At least one of name or is_public is required to update"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE Playlists SET name = ?, is_public = ?, updated_at = GETDATE() WHERE playlist_id = ?",
            (data.get("name"), data.get("is_public"), playlist_id)
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "Playlist updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Failed to update playlist: {e}"}), 500

# DELETE: Delete a playlist
@playlist_routes.route("/playlists/<int:playlist_id>", methods=["DELETE"])
def delete_playlist(playlist_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # First, delete associated records from Playlist_Songs
        cursor.execute("DELETE FROM Playlist_Songs WHERE playlist_id = ?", (playlist_id,))
        # Then, delete the playlist
        cursor.execute("DELETE FROM Playlists WHERE playlist_id = ?", (playlist_id,))
        
        conn.commit()
        conn.close()
        return jsonify({"message": "Playlist deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Failed to delete playlist: {e}"}), 500

# GET: Fetch a specific playlist
@playlist_routes.route("/playlists/<int:playlist_id>", methods=["GET"])
def get_playlist_by_id(playlist_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Playlists WHERE playlist_id = ?", (playlist_id,))
        row = cursor.fetchone()
        conn.close()

        if row:
            return jsonify({
                "playlist_id": row[0],
                "user_id": row[1],
                "name": row[2],
                "is_public": row[3],
                "created_at": row[4],
                "updated_at": row[5]
            })
        else:
            return jsonify({"error": "Playlist not found"}), 404
    except Exception as e:
        return jsonify({"error": f"Failed to fetch playlist: {e}"}), 500

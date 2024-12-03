import pyodbc
from flask import Blueprint, jsonify, request
from datetime import datetime
from config import DB_CONFIG

artist_routes = Blueprint('artist_routes', __name__)

def get_db_connection():
    return pyodbc.connect(
        f"DRIVER={{{DB_CONFIG['DRIVER']}}};SERVER={DB_CONFIG['SERVER']};"
        f"DATABASE={DB_CONFIG['DATABASE']};UID={DB_CONFIG['UID']};PWD={DB_CONFIG['PWD']}"
    )

# GET: Fetch all artists
@artist_routes.route("/", methods=["GET"])
def get_artists():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Artists")
        artists = cursor.fetchall()
        conn.close()
        return jsonify([
            {
                "artist_id": row[0],
                "name": row[1],
                "bio": row[2],
                "image_url": row[3],
                "created_at": row[4],
                "updated_at": row[5]
            } for row in artists
        ])
    except Exception as e:
        return jsonify({"error": f"Database Connection Error: {e}"}), 500

# POST: Add a new artist
@artist_routes.route("/", methods=["POST"])
def create_artist():
    data = request.get_json()

    if "artist_id" not in data or "name" not in data:
        return jsonify({"error": "artist_id and name are required"}), 400

    created_at = datetime.now()
    updated_at = created_at

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO Artists (artist_id, name, bio, image_url, created_at, updated_at) "
            "VALUES (?, ?, ?, ?, ?, ?)",
            (data["artist_id"], data["name"], data.get("bio"), data.get("image_url"), created_at, updated_at)
        )
        conn.commit()
        conn.close()
        print("Artist added successfully")  # Debug confirmation
        return jsonify({"message": "Artist added successfully"}), 201
    except Exception as e:
        return jsonify({"error": f"Failed to add artist: {e}"}), 500

# PUT: Update an artist
@artist_routes.route("/<int:artist_id>", methods=["PUT"])
def update_artist(artist_id):
    data = request.get_json()
    if not data or "name" not in data:
        return jsonify({"error": "Invalid input"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE Artists SET name = ?, bio = ?, image_url = ?, updated_at = GETDATE() "
            "WHERE artist_id = ?",
            (data["name"], data.get("bio"), data.get("image_url"), artist_id)
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "Artist updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Failed to update artist: {e}"}), 500


# DELETE: Remove an artist
@artist_routes.route("/<int:artist_id>", methods=["DELETE"])
def delete_artist(artist_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Songs WHERE artist_id = ?", (artist_id,))

        cursor.execute("DELETE FROM Albums WHERE artist_id = ?", (artist_id,))
        cursor.execute("DELETE FROM Contribution_Album_Table WHERE artist_id = ?", (artist_id,))
        cursor.execute("DELETE FROM Contribution_Song_Table WHERE artist_id = ?", (artist_id,))
        cursor.execute("DELETE FROM Artists WHERE artist_id = ?", (artist_id,))
        conn.commit()
        conn.close()
        return jsonify({"message": "Artist deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Failed to delete artist: {e}"}), 500

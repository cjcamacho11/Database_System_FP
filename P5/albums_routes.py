import pyodbc
from flask import Blueprint, jsonify, request
from config import DB_CONFIG

albums_routes = Blueprint('albums_routes', __name__)


def get_db_connection():
    return pyodbc.connect(
        f"DRIVER={{{DB_CONFIG['DRIVER']}}};SERVER={DB_CONFIG['SERVER']};"
        f"DATABASE={DB_CONFIG['DATABASE']};UID={DB_CONFIG['UID']};PWD={DB_CONFIG['PWD']}"
    )


# GET: Fetch all albums
@albums_routes.route("/albums", methods=["GET"])
def get_albums():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Albums")
        albums = cursor.fetchall()
        conn.close()

        return jsonify([
            {
                "album_id": row[0],
                "title": row[1],
                "artist_id": row[2],
                "release_date": row[3],
                "cover_image_url": row[4]
            } for row in albums
        ])
    except Exception as e:
        return jsonify({"error": f"Failed to fetch albums: {e}"}), 500


# POST: Add a new album
@albums_routes.route("/albums", methods=["POST"])
def create_album():
    data = request.get_json()
    if "title" not in data or "artist_id" not in data:
        return jsonify({"error": "title and artist_id are required fields"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO Albums (title, artist_id, release_date, cover_image_url) VALUES (?, ?, ?, ?)",
            (data["title"], data["artist_id"], data.get("release_date"), data.get("cover_image_url"))
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "Album created successfully"}), 201
    except Exception as e:
        return jsonify({"error": f"Failed to create album: {e}"}), 500


# PUT: Update an existing album
@albums_routes.route("/albums/<int:album_id>", methods=["PUT"])
def update_album(album_id):
    data = request.get_json()
    if "title" not in data and "artist_id" not in data and "release_date" not in data and "cover_image_url" not in data:
        return jsonify(
            {"error": "At least one field (title, artist_id, release_date, cover_image_url) must be provided"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE Albums SET title = COALESCE(?, title), artist_id = COALESCE(?, artist_id), "
            "release_date = COALESCE(?, release_date), cover_image_url = COALESCE(?, cover_image_url) "
            "WHERE album_id = ?",
            (data.get("title"), data.get("artist_id"), data.get("release_date"), data.get("cover_image_url"), album_id)
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "Album updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Failed to update album: {e}"}), 500


# DELETE: Remove an album
@albums_routes.route("/albums/<int:album_id>", methods=["DELETE"])
def delete_album(album_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        # Delete related records in Songs table
        cursor.execute("DELETE FROM Songs WHERE album_id = ?", (album_id,))

        # Delete the album itself
        cursor.execute("DELETE FROM Albums WHERE album_id = ?", (album_id,))

        conn.commit()
        conn.close()
        return jsonify({"message": "Album and related songs deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Failed to delete album: {e}"}), 500


# GET: Fetch a specific album by ID
@albums_routes.route("/albums/<int:album_id>", methods=["GET"])
def get_album_by_id(album_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Albums WHERE album_id = ?", (album_id,))
        row = cursor.fetchone()
        conn.close()

        if row:
            return jsonify({
                "album_id": row[0],
                "title": row[1],
                "artist_id": row[2],
                "release_date": row[3],
                "cover_image_url": row[4]
            })
        else:
            return jsonify({"error": "Album not found"}), 404
    except Exception as e:
        return jsonify({"error": f"Failed to fetch album: {e}"}), 500

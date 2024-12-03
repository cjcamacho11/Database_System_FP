import pyodbc
from flask import Blueprint, jsonify, request
from config import DB_CONFIG

song_routes = Blueprint('song_routes', __name__)

def get_db_connection():
    return pyodbc.connect(
        f"DRIVER={{{DB_CONFIG['DRIVER']}}};SERVER={DB_CONFIG['SERVER']};"
        f"DATABASE={DB_CONFIG['DATABASE']};UID={DB_CONFIG['UID']};PWD={DB_CONFIG['PWD']}"
    )

# GET: Fetch all songs
@song_routes.route("/", methods=["GET"])
def get_songs():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Songs")
        songs = cursor.fetchall()
        conn.close()
        return jsonify([
            {
                "song_id": row[0],
                "title": row[1],
                "artist_id": row[2],
                "album_id": row[3],
                "genre_id": row[4],
                "release_date": row[5].strftime("%Y-%m-%d") if row[5] else None,
                "duration": row[6]
            } for row in songs
        ])
    except Exception as e:
        return jsonify({"error": f"Database Connection Error: {e}"}), 500

# POST: Add a new song
@song_routes.route("/", methods=["POST"])
def add_song():
    data = request.get_json()

    if "song_id" not in data or "title" not in data:
        return jsonify({"error": "song_id and title are required"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO Songs (song_id, title, artist_id, album_id, genre_id, release_date, duration) "
            "VALUES (?, ?, ?, ?, ?, ?, ?)",
            (data["song_id"], data["title"], data["artist_id"], data.get("album_id"),
             data.get("genre_id"), data["release_date"], data["duration"])
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "Song added successfully"}), 201
    except Exception as e:
        return jsonify({"error": f"Failed to add song: {e}"}), 500

# PUT: Update a song
@song_routes.route("/<int:song_id>", methods=["PUT"])
def update_song(song_id):
    data = request.get_json()
    if not data:

        return jsonify({"error": "Invalid input"}), 400

    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute(
            "UPDATE Songs SET title = ?, artist_id = ?, album_id = ?, genre_id = ?, release_date = ?, duration = ? "
            "WHERE song_id = ?",
            (data.get("title"), data.get("artist_id"), data.get("album_id"), data.get("genre_id"),
             data.get("release_date"), data.get("duration"), song_id)
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "Song updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Failed to update song: {e}"}), 500


# DELETE: Remove a song
@song_routes.route("/<int:song_id>", methods=["DELETE"])
def delete_song(song_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("DELETE FROM Playlist_Songs WHERE song_id = ?", (song_id,))
        cursor.execute("DELETE FROM Contribution_Song_Table WHERE song_id = ?", (song_id,))
        cursor.execute("DELETE FROM Songs WHERE song_id = ?", (song_id,))

        conn.commit()
        conn.close()
        return jsonify({"message": "Song deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": f"Failed to delete song: {e}"}), 500

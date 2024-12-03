from flask import Flask
from user_routes import api
from playlist_routes import playlist_routes
from artist_routes import artist_routes
from song_routes import song_routes

app = Flask(__name__)

app.register_blueprint(api, url_prefix="/api")
app.register_blueprint(playlist_routes, url_prefix="/api/playlists")
app.register_blueprint(artist_routes, url_prefix="/api/artists")
app.register_blueprint(song_routes, url_prefix="/api/songs")


if __name__ == "__main__":
    app.run(debug=True)
from flask import Flask
from user_routes import api  
from playlist_routes import playlist_routes

app = Flask(__name__)

app.register_blueprint(api, url_prefix="/api")  
app.register_blueprint(playlist_routes, url_prefix="/api/playlists")


if __name__ == "__main__":
    app.run(debug=True)

import pyodbc
from flask import Flask, jsonify

app = Flask(__name__)

# Database connection details
DB_CONFIG = {
    "DRIVER": "ODBC Driver 17 for SQL Server",
    "SERVER": "localhost",
    "DATABASE": "MusicMedia",
    "UID": "SA",
    "PWD": "YourPassword",
    "Timeout": 60
}

# Route to fetch all Users
@app.route("/users")
def get_users():
    try:
        conn = pyodbc.connect(
            'DRIVER={{{}}};SERVER={};PORT=1433;DATABASE={};UID={};PWD={}'.format(
                DB_CONFIG['DRIVER'], DB_CONFIG['SERVER'], DB_CONFIG['DATABASE'],
                DB_CONFIG['UID'], DB_CONFIG['PWD'])
        )
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Users")
        users = cursor.fetchall()
        conn.close()
        
        return jsonify([{"user_id": user[0], "username": user[1], "email": user[2]} for user in users])
    except Exception as e:
        return f"Database connection error: {e}"

if __name__ == "__main__":
    app.run(debug=True)

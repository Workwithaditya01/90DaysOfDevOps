from flask import Flask
import os
import psycopg2
import redis

app = Flask(__name__)

@app.route("/")
def home():
    db_status = "Connected"
    redis_status = "Connected"

    try:
        psycopg2.connect(
            host=os.getenv("DB_HOST"),
            database=os.getenv("DB_NAME"),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD")
        )
    except:
        db_status = "Not Connected"

    try:
        redis.Redis(host=os.getenv("REDIS_HOST"), port=6379).ping()
    except:
        redis_status = "Not Connected"

    return f"""
    <h2>Docker Compose Advanced Demo</h2>
    <p>Database: {db_status}</p>
    <p>Redis: {redis_status}</p>
    """

app.run(host="0.0.0.0", port=5000)

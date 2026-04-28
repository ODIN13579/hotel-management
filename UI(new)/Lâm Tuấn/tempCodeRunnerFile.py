from flask import Flask, render_template, request, redirect
from db import get_connection

app = Flask(__name__)

# ================= LOGIN =================
@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        user = request.form["username"]
        pw = request.form["password"]

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""SELECT * FROM Users WHERE Email = ? AND Password = ?""", (user, pw))
        result = cursor.fetchone()

        if result:
            return redirect("/dashboard")
        else:
            return "Sai tài khoản"

    return render_template("login.html")


# ================= DASHBOARD =================
@app.route("/dashboard")
def dashboard():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Users")
    users = cursor.fetchall()

    return render_template("dashboard.html", users=users)


# ================= ADD USER =================
@app.route("/add", methods=["GET", "POST"])
def add():
    if request.method == "POST":
        user = request.form["username"]
        pw = request.form["password"]

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO Users(User_ID, Name, Email, Phone, Password)
            VALUES (?, ?, ?, ?, ?)
        """, ("U011", "Test", user, user, pw))
        conn.commit()

        return redirect("/dashboard")

    return render_template("add.html")


app.run(host="0.0.0.0", port=5000, debug=True)
from flask import Flask, render_template, request, redirect
from db import get_connection
import uuid

app = Flask(__name__)

# ================= LOGIN =================
@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        user = request.form["username"]
        pw = request.form["password"]
        error = None

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM Users WHERE Email = ? AND Password = ?", (user, pw))
        result = cursor.fetchone()

        if result:
            return redirect("/dashboard")
        else:
            error = "Tải khoản hoặc mật khẩu không đúng!" 
            

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
@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        uid = "U" + str(uuid.uuid4())[:5] 
        name = request.form.get("name")
        mail = request.form.get("mail")
        np = request.form.get("numberphone")
        pw = request.form.get("password")

        # if not name or not mail or not np or not pw:
        #     if not name:
        #         return "Name is missing"
        #     if not mail:
        #         return "Email is missing"
        #     if not np:
        #         return "Phone is missing"
        #     if not pw:
        #         return "Password is missing"
        #     return "Thiếu dữ liệu!"

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO Users(User_ID, Name, Email, Phone, Password)
            VALUES (?, ?, ?, ?, ?)
        """, (uid, name, mail, np, pw))
        conn.commit()

        return redirect("/")  

    return render_template("register.html")

# @app.route("/forgotpass", methods=["GET", "POST"])
# def forgot():
#     if request.method == "POST":
#         mail = request.form.get("mail")
#         pass = request.form.get("password")
#     return render_template("forgotpass.html")

app.run(host="0.0.0.0", port=5000, debug=True)

from flask import Flask, render_template, request, redirect
from db import get_connection
from datetime import datetimes
import uuid

app = Flask(__name__)

# ================= LOGIN =================
@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        user = request.form["username"]
        pw = request.form["password"]
        

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM Users WHERE Email = ? AND Password = ?", (user, pw))
        result = cursor.fetchone()

        if result:
            return redirect("/dashboard")
        else:
            cursor.execute("""SELECT * FROM Employees WHERE Email = ? AND Password = ?""", (user, pw))
            result_admin = cursor.fetchone()
            
            if result_admin:
                return redirect("/management")
            
    return render_template("login.html")


# ================= DASHBOARD =================
@app.route("/dashboard")
def dashboard():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Rooms")
    rooms = cursor.fetchall()

    cursor.execute("SELECT * FROM Reviews")
    reviews = cursor.fetchall()

    return render_template("dashboard.html", rooms=rooms, reviews=reviews)


# ================= ADD USER =================
@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        uid = "U" + str(uuid.uuid4())[:5] 
        name = request.form.get("name")
        mail = request.form.get("mail")
        np = request.form.get("numberphone")
        pw = request.form.get("password")

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("""
            INSERT INTO Users(User_ID, Name, Email, Phone, Password)
            VALUES (?, ?, ?, ?, ?)
        """, (uid, name, mail, np, pw))
        conn.commit()

        return redirect("/")  

    return render_template("register.html")

#===============Forgot Password================
@app.route("/forgotpass", methods=["GET", "POST"])
def forgotpass():
    if request.method == "POST":
        mail = request.form.get("mail")
        newPw = request.form.get("newPassword")

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("EXEC UpdatePassword ?, ?", (mail, newPw))
        conn.commit()

        return redirect("/")    
    return render_template("forgotpass.html")

#===============Detail Room================
@app.route("/room_detail", methods=["GET", "POST"])
def room_detail():
    if request.method == "POST":
        room_id = request.form["room_id"]

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM Rooms WHERE Room_ID = ?", (room_id,))
        room = cursor.fetchone()

        cursor.execute("SELECT dbo.GetRatingRoom(?)", (room_id,))
        review = cursor.fetchone()[0]
        
        cursor.execute("SELECT dbo.GetRoomType(?)", (room_id,))
        room_type = cursor.fetchone()[0]

        show_VIP = room_type == "VIP"
        show_Deluxe = room_type in  ["Deluxe", "VIP"]

        return render_template("room_detail.html", room=room, review=review, show_Deluxe=show_Deluxe, show_VIP=show_VIP)
    return "Không có dữ liệu"
        

#===============Confirm================
@app.route("/confirm", methods=["POST"])
def confirm():
    room_id = request.form.get("room_id")
    checkin = request.form.get("checkin")
    checkout = request.form.get("checkout")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Rooms WHERE Room_ID = ?", (room_id,))
    room = cursor.fetchone()

    # tính số đêm
    d1 = datetime.strptime(checkin, "%Y-%m-%d")
    d2 = datetime.strptime(checkout, "%Y-%m-%d")
    nights = (d2 - d1).days

    # tránh lỗi âm
    if nights <= 0:
        nights = 1

    total = nights * room[4]


    return render_template(
        "confirm.html",
        room=room,
        checkin=checkin,
        checkout=checkout,
        nights=nights,
        total=total
    )

@app.route("/management")
def tong_quan():
    
    return render_template("tong_quan.html")

@app.route("/bookings")
def bookings():
    return render_template("dat_phong.html")

@app.route("/rooms")
def quan_ly_phong():
    return render_template("phong.html")

@app.route("/services")
def quan_ly_dich_vu():
    return render_template("dich_vu.html")

@app.route("/payments")
def quan_ly_thanh_toan():
    return render_template("thanh_toan.html")

@app.route("/invoices")
def quan_ly_hoa_don():
    return render_template("hoa_don.html")

@app.route("/staff")
def quan_ly_nhan_vien():
    return render_template("nhan_vien.html")


app.run(host="0.0.0.0", port=5000, debug=True)

from flask import Flask, render_template, request, redirect
import uuid

app = Flask(__name__)

# ================= DATA CHUNG =================
ROOMS = {
    1: {
        "id": 1,
        "name": "Deluxe Double Room",
        "price": "1.200.000đ",
        "location": "Đà Lạt",
        "rating": 4.5,
        "desc": "Phòng rộng rãi, view đẹp",
        "image": "PhongDoi.png",
        "images": ["PhongDoi.png", "NhaVS.png", "PhongDoi.png"],
        "amenities": ["Wifi", "TV", "Máy lạnh"]
    },
    2: {
        "id": 2,
        "name": "VIP Suite",
        "price": "2.000.000đ",
        "location": "Đà Lạt",
        "rating": 4.8,
        "desc": "Phòng cao cấp, sang trọng",
        "image": "NhaVS.png",
        "images": ["NhaVS.png", "PhongDoi.png", "NhaVS.png"],
        "amenities": ["Wifi", "Netflix", "Bồn tắm"]
    },
    3: {
        "id": 3,
        "name": "Standard Room",
        "price": "900.000đ",
        "location": "Đà Lạt",
        "rating": 4.2,
        "desc": "Phòng cơ bản, tiện nghi đầy đủ",
        "image": "PhongDoi.png",
        "images": ["PhongDoi.png"],
        "amenities": ["Wifi", "TV"]
    }
}

# ================= LOGIN =================
@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        user = request.form["username"]
        pw = request.form["password"]

        if user == "admin@gmail.com" and pw == "123":
            return redirect("/dashboard")
        else:
            return "Sai tài khoản hoặc mật khẩu!"

    return render_template("login.html")

# ================= DASHBOARD =================
@app.route("/dashboard")
def dashboard():
    return render_template("dashboard.html", rooms=ROOMS.values())

# ================= ROOM DETAIL =================
@app.route('/room/<int:room_id>')
def room_detail(room_id):
    room = ROOMS.get(room_id)

    if not room:
        return "Room not found", 404

    return render_template("room_detail.html", room=room)

# ================= REGISTER =================
@app.route("/register", methods=["GET", "POST"])
def register():
    if request.method == "POST":
        uid = "U" + str(uuid.uuid4())[:5]
        name = request.form.get("name")
        mail = request.form.get("mail")
        np = request.form.get("numberphone")
        pw = request.form.get("password")

        print(uid, name, mail, np, pw)

        return redirect("/")

    return render_template("register.html")

app.run(host="0.0.0.0", port=5000, debug=True)
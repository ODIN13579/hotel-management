from flask import Flask, render_template, request, redirect
from _db import get_connection
from datetime import datetime
import uuid

app = Flask(__name__)

def get_dashboard_summary():
    conn = get_connection()
    cursor = conn.cursor()
    try:
        cursor.execute("EXEC sp_GetDashboardSummary")
        row = cursor.fetchone()
        
        if row:
            return {
        'TotalRooms': row.TotalRooms,
        'TodayBookings': row.TodayBookings,
        'MonthlyRevenue': row.MonthlyRevenue,
        'Trong': row.Trong,   
        'DaDat': row.DaDat,   
        'DaNhan': row.DaNhan, 
        'BaoTri': row.BaoTri  
    }
        return None
    except Exception as e:
        print(f"Lỗi truy vấn: {e}")
        return None
    finally:
        conn.close()

def get_recent_bookings():
    conn = get_connection()
    cursor = conn.cursor()
    try:
        # Lấy dữ liệu từ View đã tạo trong SQL Server
        cursor.execute("SELECT * FROM v_DashboardRecentBookings")
        
        # Chuyển đổi kết quả thành danh sách các Dictionary
        columns = [column[0] for column in cursor.description]
        bookings = []
        for row in cursor.fetchall():
            bookings.append(dict(zip(columns, row)))
            
        return bookings
    except Exception as e:
        print(f"Lỗi khi lấy danh sách đặt phòng: {e}")
        return []
    finally:
        conn.close()



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

# ================ MANAGEMENT =================
@app.route("/management")
def tong_quan():    
    return render_template("tong_quan.html")
    stats_data = get_dashboard_summary()
    recent_data = get_recent_bookings()
    
    if not stats_data:
        stats_data = {
            'TotalRooms': 0,
            'TodayBookings': 0,
            'MonthlyRevenue': 0.00,
            'Trong': 0,
            'DaDat': 0,
            'DaNhan': 0,
            'BaoTri': 0
        }
    return render_template("tong_quan.html",
                            stats=stats_data,
                            recent_bookings=recent_data)

@app.route("/bookings")
def bookings():
    return render_template("dat_phong.html")

@app.route("/rooms")
def quan_ly_phong():
    return render_template("phong.html")

@app.route("/services")
def quan_ly_dich_vu():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Services")
    services = cursor.fetchall()

    conn.close()

    return render_template("dich_vu.html", services=services)


@app.route("/services/add", methods=["POST"])
def add_service():
    sid = "S" + str(uuid.uuid4())[:5]
    name = request.form.get("name")
    description = request.form.get("description")
    price = request.form.get("price")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO Services(Service_ID, Name, Description, Price)
        VALUES (?, ?, ?, ?)
    """, (sid, name, description, price))

    conn.commit()
    conn.close()

    return redirect("/services")


@app.route("/services/delete/<service_id>")
def delete_service(service_id):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("DELETE FROM Services WHERE Service_ID = ?", (service_id,))
    conn.commit()
    conn.close()

    return redirect("/services")


@app.route("/services/update", methods=["POST"])
def update_service():
    service_id = request.form.get("service_id")
    name = request.form.get("name")
    description = request.form.get("description")
    price = request.form.get("price")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE Services
        SET Name = ?, Description = ?, Price = ?
        WHERE Service_ID = ?
    """, (name, description, price, service_id))

    conn.commit()
    conn.close()

    return redirect("/services")


@app.route("/payments")
def quan_ly_thanh_toan():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Payment")
    payments = cursor.fetchall()

    conn.close()

    return render_template("thanh_toan.html", payments=payments)


@app.route("/payments/update-status", methods=["POST"])
def update_payment_status():
    payment_id = request.form.get("payment_id")
    status = request.form.get("status")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE Payment
        SET Status = ?
        WHERE Payment_ID = ?
    """, (status, payment_id))

    conn.commit()
    conn.close()

    return redirect("/payments")


@app.route("/payments/delete/<payment_id>")
def delete_payment(payment_id):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("DELETE FROM Payment WHERE Payment_ID = ?", (payment_id,))

    conn.commit()
    conn.close()

    return redirect("/payments")
    return render_template("dich_vu.html")

@app.route("/payments")
def quan_ly_thanh_toan():
    return render_template("thanh_toan.html")

@app.route("/invoices")
def quan_ly_hoa_don():
    return render_template("hoa_don.html")

@app.route("/staff")
def quan_ly_nhan_vien():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Employees")
    employees = cursor.fetchall()

    conn.close()

    return render_template("nhan_vien.html", employees=employees)


@app.route("/staff/add", methods=["POST"])
def add_staff():
    eid = "E" + str(uuid.uuid4())[:5]
    name = request.form.get("name")
    email = request.form.get("email")
    phone = request.form.get("phone")
    password = request.form.get("password")
    role = request.form.get("role")
    status = request.form.get("status")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        INSERT INTO Employees(Employee_ID, Name, Email, Phone, Password, Role, Status)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """, (eid, name, email, phone, password, role, status))
    conn.commit()
    conn.close()

    return redirect("/staff")


@app.route("/staff/update", methods=["POST"])
def update_staff():
    employee_id = request.form.get("employee_id")
    name = request.form.get("name")
    email = request.form.get("email")
    phone = request.form.get("phone")
    password = request.form.get("password")
    role = request.form.get("role")
    status = request.form.get("status")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE Employees
        SET Name = ?, Email = ?, Phone = ?, Password = ?, Role = ?, Status = ?
        WHERE Employee_ID = ?
    """, (name, email, phone, password, role, status, employee_id))

    conn.commit()
    conn.close()

    return redirect("/staff")


@app.route("/staff/update-status", methods=["POST"])
def update_staff_status():
    employee_id = request.form.get("employee_id")
    status = request.form.get("status")

    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE Employees
        SET Status = ?
        WHERE Employee_ID = ?
    """, (status, employee_id))

    conn.commit()
    conn.close()

    return redirect("/staff")


@app.route("/staff/delete/<employee_id>")
def delete_staff(employee_id):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute(
        "DELETE FROM Employees WHERE Employee_ID = ?",
        (employee_id,)
    )

    conn.commit()
    conn.close()

    return redirect("/staff")
if __name__ == "__main__":

  app.run(host="0.0.0.0", port=5000, debug=True)
    return render_template("nhan_vien.html")


app.run(host="0.0.0.0", port=5000, debug=True)

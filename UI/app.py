from flask import Flask, render_template, request, redirect, send_from_directory, url_for
from flask import session
from db import get_connection
from datetime import datetime
import re
import uuid
import os

app = Flask(__name__)
app.secret_key = "abc123"

IMAGE_ROOT = os.path.join(app.root_path, "static", "10_phong")  # hoặc thư mục bạn đang chứa ảnh

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

# ================= ROUTE LẤY ẢNH TỪ THƯ MỤC STATIC =================
@app.route('/room_images/<path:filename>')
def room_images(filename):
    # Chỉ đường cho Flask tới thư mục "10_phong" nằm TRONG thư mục static
    image_dir = os.path.join(app.root_path, 'static', '10_phong')
    return send_from_directory(image_dir, filename)

# ================= LOGIN =================
@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        user = request.form["username"]
        pw = request.form["password"]
        

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM LoginUser(?, ?)", (user, pw))
        result = cursor.fetchone()

        if result:
            session["user_id"] = result[0]
            # if not user_id:
            #     return redirect("/")
            return redirect("/dashboard")
        else:
            cursor.execute("SELECT * FROM LoginManager  (?, ?)", (user, pw))
            result_admin = cursor.fetchone()
            
            if result_admin:
                session["admin"] = {
                    "id": result_admin[0],
                    "name": result_admin[1],
                    "role": result_admin[5]
                }
                return redirect("/management")
            
    return render_template("login.html")

# ================= DASHBOARD =================
@app.route("/dashboard")
def dashboard():
    conn = get_connection()
    cursor = conn.cursor()

    user_id = session.get("user_id")

    cursor.execute("EXEC RoomHaveRating")
    rooms = cursor.fetchall()

    cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
    user = cursor.fetchone()

    # ===== IMAGE MAP =====
    image_map = {
        "R01": "p1/p1_01.webp",
        "R02": "p2/p2_01.webp",
        "R03": "p3/p3_01.webp",
        "R04": "p4/p4_01.webp",
        "R05": "p5/p5_01.webp",
        "R06": "p6/p6_01.webp",
        "R07": "p7/p7_01.webp",
        "R08": "p8/p8_01.webp",
        "R09": "p9/p9_01.webp",
        "R10": "p10/p10_01.webp",
    }

    return render_template(
        "dashboard.html", 
        rooms=rooms,  
        user=user, 
        image_map=image_map
    )


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

        cursor.execute("EXEC CreateAccount ?, ?, ?, ?, ?", (uid, name, mail, np, pw))
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
@app.route("/10_phong/<folder>/<filename>")
def serve_room_image(folder, filename):
    return send_from_directory(
        os.path.join(IMAGE_ROOT, folder),
        filename
    )

@app.route("/room_detail", methods=["GET", "POST"])
def room_detail():
    if request.method == "POST":
        room_id = request.form["room_id"]
        
        user_id = session.get("user_id")

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM GetRoom(?)", (room_id,))
        room = cursor.fetchone()

        cursor.execute("SELECT dbo.AvgRatingRoom(?)", (room_id,))
        rating = cursor.fetchone()[0]
        
        cursor.execute("SELECT dbo.GetRoomType(?)", (room_id,))
        room_type = cursor.fetchone()[0]

        show_VIP = room_type == "VIP"
        show_Deluxe = room_type == "Deluxe"
        show_Standard = room_type not in ["Deluxe", "VIP"]

        cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
        user = cursor.fetchone()


        number = re.search(r"\d+", room_id).group()
        folder = "p" + str(int(number))

        base_path = os.path.join(IMAGE_ROOT, folder)

        images = []

        if os.path.exists(base_path):
            for file in sorted(os.listdir(base_path)):
                if file.endswith((".webp", ".jpg", ".png")):
                    images.append(url_for('static', filename=f"10_phong/{folder}/{file}"))
        
        # Lấy review
        cursor.execute("SELECT * FROM GetReview(?)", (room_id,))
        reviews = cursor.fetchall()

        # Lấy amenities
        cursor.execute("SELECT * FROM Services")
        services = cursor.fetchall()

        return render_template(
            "room_detail.html", 
            room=room, 
            rating=rating,
            show_Standard=show_Standard,
            show_Deluxe=show_Deluxe,
            show_VIP=show_VIP, 
            user=user,
            images=images,
            reviews=reviews,
            services=services
        )
    return "Không có dữ liệu"
        

#===============Confirm================
@app.route("/confirm", methods=["POST"])
def confirm():
    room_id = request.form.get("room_id")
    checkin = request.form.get("checkin")
    checkout = request.form.get("checkout")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM GetRoom(?)", (room_id,))
    room = cursor.fetchone()

    # tính số đêm
    d1 = datetime.strptime(checkin, "%Y-%m-%d")
    d2 = datetime.strptime(checkout, "%Y-%m-%d")
    nights = (d2 - d1).days

    # tránh lỗi âm
    if nights <= 0:
        nights = 1

    total = nights * room[4]
    
    user_id = session.get("user_id")
    cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
    user = cursor.fetchone()

    # ===== LẤY ẢNH TỪ FOLDER NGOÀI =====

    number = re.search(r"\d+", room_id).group()
    folder = "p" + str(int(number))

    base_path = os.path.join(IMAGE_ROOT, folder)

    images = []

    if os.path.exists(base_path):
        for file in sorted(os.listdir(base_path)):
            if file.endswith((".webp", ".jpg", ".png")):
                images.append(url_for('static', filename=f"10_phong/{folder}/{file}"))

    return render_template(
        "confirm.html",
        room=room,
        checkin=checkin,
        checkout=checkout,
        nights=nights,
        total=total,
        user=user,
        images=images
    )

#===============Previous booking================
@app.route("/booking_previous", methods=["GET", "POST"])
def booking_previous():
    user_id = session.get("user_id")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
    user = cursor.fetchone()

    cursor.execute("SELECT * FROM GetBooking(?)", (user_id,))
    bookings = cursor.fetchall()

    image_map = {
        "R01": "p1/p1_01.webp",
        "R02": "p2/p2_01.webp",
        "R03": "p3/p3_01.webp",
        "R04": "p4/p4_01.webp",
        "R05": "p5/p5_01.webp",
        "R06": "p6/p6_01.webp",
        "R07": "p7/p7_01.webp",
        "R08": "p8/p8_01.webp",
        "R09": "p9/p9_01.webp",
        "R10": "p10/p10_01.webp",
    }


    return render_template("booking_previous.html", 
                           user=user,
                           bookings=bookings,
                           image_map=image_map
                        )


@app.route("/cancel_booking_user/<id>")
def cancel_booking_user(id):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE Bookings
        SET Status = N'đã hủy'
        WHERE Booking_ID = ?
    """, (id,))

    conn.commit()
    conn.close()

    return redirect("/booking_previous")

#===============Reivew================
@app.route("/reviews/<booking_id>", methods=["GET", "POST"])
def reviews(booking_id):
    conn = get_connection()
    cursor = conn.cursor()

    user_id = session.get("user_id")
    
    cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
    user = cursor.fetchone()

    cursor.execute("SELECT * FROM Bookings WHERE Booking_ID = ?", (booking_id,))
    booking = cursor.fetchone()

    if request.method == "POST":
        # name = request.form.get("name")
        rating = request.form.get("rating")
        comment = request.form.get("comment")

        review_id = "REV" + str(uuid.uuid4())[:3]
        day = datetime.now().strftime("%d/%m/%Y")

        cursor.execute("EXEC CreateReview ?, ?, ?, ?, ?, ?", (review_id, user_id, booking_id, rating, comment, day))
        conn.commit()
        conn.close()

        return redirect("/dashboard")

    return render_template("reviews.html",
                            user=user,
                            booking=booking   
                        )

#===============Payment================
@app.route("/payment", methods=["GET", "POST"])
def payment():
    user_id = session.get("user_id")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
    user = cursor.fetchone()

    booking_id = "B" + str(uuid.uuid4())[:3]
    payment_id = "P" + str(uuid.uuid4())[:3]
    day = datetime.now().date()
    status = "Đã xác nhận"

    if request.method == "POST":
        # lấy dữ liệu từ confirm
        room_id = request.form.get("room_id")
        checkin = request.form.get("checkin")
        checkout = request.form.get("checkout")
        total = float(request.form.get("total"))

        # tạo ID
        booking_id = "B" + str(uuid.uuid4())[:3]
        payment_id = "P" + str(uuid.uuid4())[:3]
        day = datetime.now().strftime("%d/%m/%Y")
        status = "đang chờ xử lý"

        room_id = request.form.get("room_id")

        cursor.execute("SELECT * FROM GetRoom(?)", (room_id,))
        room = cursor.fetchone()

        return render_template("payment.html",
                               user=user,
                               booking_id=booking_id,
                               payment_id=payment_id,
                               total=total,
                               day=day,
                               status=status,
                               room_id=room_id,
                               checkin=checkin,
                               checkout=checkout,
                               room=room)

    return redirect("/dashboard")


@app.route("/process_payment", methods=["POST"])
def process_payment():
    conn = get_connection()
    cursor = conn.cursor()

    booking_id = request.form.get("booking_id")
    payment_id = request.form.get("payment_id")

    total_str = request.form.get("total")
    # xoá dấu , . đ
    total_str = total_str.replace(",", "").replace(".", "").replace("đ", "").strip()
    total = float(total_str)
    
    room_id = request.form.get("room_id")
    checkin = datetime.strptime(request.form.get("checkin"), "%Y-%m-%d")
    checkout = datetime.strptime(request.form.get("checkout"), "%Y-%m-%d")
    booking_date = datetime.now()
    status_booking = "đã xác nhận"
    user_id = session.get("user_id")
    employee_id = "E02"

    # INSERT BOOKING
    cursor.execute("EXEC AddBooking ?, ?, ?, ?, ?, ?, ?, ?, ?", 
                   (booking_id, user_id, room_id, employee_id, booking_date, total, checkin, checkout, status_booking))

    # INSERT PAYMENT
    status_payment = "thành công"
    cursor.execute("EXEC CreatePayment ?, ?, ?, ?, ?", (payment_id, booking_id, total, booking_date, status_payment))

    conn.commit()
    conn.close()

    return redirect("/dashboard")


# ================ LOGOUT =================
@app.route("/logout")
def logout():
    session.clear()
    return redirect("/")

# ================ MANAGEMENT =================
@app.route("/management")
def tong_quan():    
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

    now = datetime.now()
    weekdays = ["thứ 2", "thứ 3", "thứ 4", "thứ 5", "thứ 6", "thứ 7", "chủ nhật"]
    current_date_vn = f"{weekdays[now.weekday()]}, {now.strftime('%d/%m/%Y')}"

    return render_template("tong_quan.html",
                            stats=stats_data,
                            recent_bookings=recent_data,
                            current_date=current_date_vn)

# ================= thông tin cá nhân =================
@app.route("/profile", methods=["GET", "POST"])
def profile():
    id = session.get("user_id")
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM GetUser(?)", (id,))
    user = cursor.fetchone()

    if request.method == "POST":
        name = request.form.get("name")
        phone = request.form.get("phone")

        cursor.execute("EXEC UpdateInforUser ?, ?, ?", (name, phone, id))
        conn.commit()

        return redirect(f"/profile/{id}")

    return render_template("profile.html", user=user)

# @app.route("/bookings")
# def bookings():
#     return render_template("dat_phong.html")

# ================= QUẢN LÝ PHÒNG =================
@app.route("/rooms")
def quan_ly_phong():
    if "admin" not in session:
        return redirect("/")

    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        # Lấy danh sách phòng
        cursor.execute("SELECT * FROM Rooms ORDER BY Room_Number")
        columns = [column[0] for column in cursor.description]
        rooms = [dict(zip(columns, row)) for row in cursor.fetchall()]
        
        # Thống kê trạng thái phòng
        stats = {
            'TatCa': len(rooms),
            'Trong': sum(1 for r in rooms if str(r.get('Status', '')).strip().lower() == 'có sẵn'),
            'DaDat': sum(1 for r in rooms if str(r.get('Status', '')).strip().lower() == 'đã đặt'),
            'DaNhan': sum(1 for r in rooms if str(r.get('Status', '')).strip().lower() == 'đã nhận'),
            'BaoTri': sum(1 for r in rooms if str(r.get('Status', '')).strip().lower() == 'bảo trì')
        }

        # --- PHẦN THÊM MỚI CHO CHỈNH SỬA ---
        # Lấy tất cả dịch vụ hiện có trong hệ thống
        cursor.execute("SELECT * FROM Services")
        cols_svc = [column[0] for column in cursor.description]
        all_services = [dict(zip(cols_svc, row)) for row in cursor.fetchall()]

        # Lấy mapping phòng và các dịch vụ phòng đó đang sở hữu
        cursor.execute("SELECT Room_ID, Service_ID FROM Rooms_Services")
        room_services_map = {}
        for row in cursor.fetchall():
            rid, sid = row[0], row[1]
            if rid not in room_services_map:
                room_services_map[rid] = []
            room_services_map[rid].append(sid)
        
        return render_template("phong.html", rooms=rooms, stats=stats, 
                               all_services=all_services, room_services_map=room_services_map)
    except Exception as e:
        print(f"Lỗi tải danh sách phòng: {e}")
        return "Lỗi hệ thống", 500
    finally:
        conn.close()
# ================= NÚT BẢO TRÌ PHÒNG =================
@app.route("/rooms/maintenance/<room_id>")
def toggle_maintenance(room_id):
    if "admin" not in session:
        return redirect("/")
        
    conn = get_connection()
    cursor = conn.cursor()
    try:
        # Gọi thủ tục SQL để đảo trạng thái phòng
        cursor.execute("EXEC sp_ToggleRoomMaintenance ?", (room_id,))
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"Lỗi khi bảo trì phòng: {e}")
    finally:
        conn.close()
        
    # Quay lại trang quản lý phòng sau khi bấm
    return redirect("/rooms")

# ================= ROUTE CẬP NHẬT PHÒNG =================
@app.route("/rooms/update", methods=["POST"])
def update_room():
    if "admin" not in session:
        return redirect("/")
        
    room_id = request.form.get("room_id")
    room_type = request.form.get("room_type")
    capacity = request.form.get("capacity")
    price = request.form.get("price")
    # Lấy mảng các Service_ID được check từ form
    selected_services = request.form.getlist("services") 

    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        # 1. Gọi Procedure cập nhật bảng Rooms
        cursor.execute("EXEC sp_UpdateRoomInfo ?, ?, ?, ?", (room_id, room_type, capacity, price))
        
        # 2. Xử lý bảng Rooms_Services (Xóa liên kết cũ, thêm liên kết mới)
        cursor.execute("DELETE FROM Rooms_Services WHERE Room_ID = ?", (room_id,))
        for svc_id in selected_services:
            cursor.execute("INSERT INTO Rooms_Services (Room_ID, Service_ID) VALUES (?, ?)", (room_id, svc_id))
        
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"Lỗi cập nhật phòng: {e}")
    finally:
        conn.close()
        
    return redirect("/rooms")

@app.route("/services")
def quan_ly_dich_vu():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Services")
    services = cursor.fetchall()

    total_services = len(services)

    conn.close()

    return render_template(
        "dich_vu.html",
        services=services,
        total_services=total_services
    )

@app.route("/services/add", methods=["POST"])
def add_service():
    sid = "S" + str(uuid.uuid4())[:5]
    name = request.form.get("name")
    description = request.form.get("description")
    price_raw = request.form.get("price") or "0"

    price_raw = price_raw.replace(".", "").replace(",", "")
    price = float(price_raw)

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
def payments():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT 
          p.Payment_ID,
          p.Booking_ID,
          p.Amount,
          p.Payment_Date,
          p.Status,
          u.Name,
          r.Room_Number
        FROM Payment p
        JOIN Bookings b ON p.Booking_ID = b.Booking_ID
        JOIN Users u ON b.User_ID = u.User_ID
        JOIN Rooms r ON b.Room_ID = r.Room_ID
    """)
    payments = cursor.fetchall()

    paid_total = 0
    pending_total = 0
    refund_total = 0

    paid_count = 0
    pending_count = 0
    refund_count = 0

    for p in payments:
        amount = p[2] or 0
        status = p[4]

        if status == "thành công":
            paid_total += amount
            paid_count += 1
        elif status == "đang chờ xử lý":
            pending_total += amount
            pending_count += 1
        elif status == "thất bại":
            refund_total += amount
            refund_count += 1

    conn.close()

    return render_template(
        "thanh_toan.html",
        payments=payments,
        paid_total=paid_total,
        pending_total=pending_total,
        refund_total=refund_total,
        paid_count=paid_count,
        pending_count=pending_count,
        refund_count=refund_count
    )

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
    # return render_template("dich_vu.html")

# @app.route("/payments")
# def quan_ly_thanh_toan():
#     return render_template("thanh_toan.html")

# ================= QUẢN LÝ HÓA ĐƠN =================
@app.route("/invoices")
def quan_ly_hoa_don():
    if "admin" not in session:
        return redirect("/")

    conn = get_connection()
    cursor = conn.cursor()
    try:
        # 1. Lấy thông số thống kê
        cursor.execute("EXEC sp_GetInvoiceStats")
        row = cursor.fetchone()
        stats = {
            'TotalInvoices': row.TotalInvoices if row else 0,
            'MonthlyRevenue': row.MonthlyRevenue if row else 0,
            'AvgPerInvoice': row.AvgPerInvoice if row else 0
        }

        # 2. Lấy danh sách hóa đơn
        cursor.execute("SELECT * FROM v_ManageInvoices ORDER BY Issued_Date DESC")
        columns = [column[0] for column in cursor.description]
        invoices = [dict(zip(columns, r)) for r in cursor.fetchall()]

        return render_template("hoa_don.html", invoices=invoices, stats=stats)
    except Exception as e:
        print(f"Lỗi tải danh sách hóa đơn: {e}")
        return "Lỗi hệ thống", 500
    finally:
        conn.close()

@app.route("/staff")
def quan_ly_nhan_vien():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Employees")
    employees = cursor.fetchall()

    total_employees = len(employees)

    conn.close()

    return render_template(
        "nhan_vien.html",
        employees=employees,
        total_employees=total_employees
    )

# ================= QUẢN LÝ ĐẶT PHÒNG =================
@app.route("/bookings")
def quan_ly_dat_phong():
    # Kiểm tra nếu không phải admin thì chuyển hướng về trang chủ
    if "admin" not in session:
        return redirect("/")

    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        # Lấy danh sách từ View
        cursor.execute("SELECT * FROM v_ManageBookings ORDER BY Check_In DESC")
        columns = [column[0] for column in cursor.description]
        bookings = [dict(zip(columns, row)) for row in cursor.fetchall()]
        
        # Đếm số lượng cho các tab trạng thái
        tabs_count = {
            'TatCa': len(bookings),
            'ChoXacNhan': sum(1 for b in bookings if b['Status'] == 'Chờ xác nhận'),
            'DaXacNhan': sum(1 for b in bookings if b['Status'] == 'Đã xác nhận'),
            'DangO': sum(1 for b in bookings if b['Status'] == 'Đã nhận phòng'),
            'DaTraPhong': sum(1 for b in bookings if b['Status'] == 'Đã trả phòng'),
            'DaHuy': sum(1 for b in bookings if b['Status'] == 'Đã hủy')
        }
        
        return render_template("dat_phong.html", bookings=bookings, tabs=tabs_count)
    except Exception as e:
        print(f"Lỗi tải trang đặt phòng: {e}")
        return "Lỗi hệ thống", 500
    finally:
        conn.close()
# ================= THÊM PHÒNG MỚI =================
@app.route("/rooms/add", methods=["POST"])
def add_room():
    if "admin" not in session:
        return redirect("/")
        
    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        # Tìm ID lớn nhất hiện tại để tính ID tiếp theo
        cursor.execute("SELECT Room_ID FROM Rooms")
        all_ids = [row[0] for row in cursor.fetchall()]
        
        # Lọc ra các ID là số và tìm số lớn nhất
        numeric_ids = [int(i) for i in all_ids if i.isdigit()]
        next_id_num = max(numeric_ids) + 1 if numeric_ids else 1
        room_id = str(next_id_num) # ID mới sẽ là "1", "2", "3"...

        # Lấy dữ liệu từ form
        room_number = request.form.get("room_number")
        room_type = request.form.get("room_type")
        capacity = request.form.get("capacity")
        price = request.form.get("price")
        status = "có sẵn"
        selected_services = request.form.getlist("services")

        # Thêm vào bảng Rooms
        cursor.execute("""
            INSERT INTO Rooms (Room_ID, Room_Number, Room_type, Capacity, Price_Per_Night, Status)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (room_id, room_number, room_type, capacity, price, status))
        
        # Thêm dịch vụ
        for svc_id in selected_services:
            cursor.execute("INSERT INTO Rooms_Services (Room_ID, Service_ID) VALUES (?, ?)", (room_id, svc_id))
            
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"Lỗi thêm phòng: {e}")
    finally:
        conn.close()
        
    return redirect("/rooms")

# ================= CÁC NÚT HÀNH ĐỘNG ĐẶT PHÒNG =================
@app.route("/bookings/confirm/<booking_id>")
def confirm_booking(booking_id):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("EXEC sp_ConfirmBooking ?", (booking_id,))
    conn.commit()
    conn.close()
    return redirect("/bookings")

@app.route("/bookings/checkin/<booking_id>")
def checkin_booking(booking_id):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("EXEC sp_CheckInBooking ?", (booking_id,))
    conn.commit()
    conn.close()
    return redirect("/bookings")

@app.route("/bookings/checkout/<booking_id>")
def checkout_booking(booking_id):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("EXEC sp_CheckOutBooking ?", (booking_id,))
    conn.commit()
    conn.close()
    return redirect("/bookings")

@app.route("/bookings/cancel/<booking_id>")
def cancel_booking(booking_id):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("EXEC sp_CancelBooking ?", (booking_id,))
    conn.commit()
    conn.close()
    return redirect("/bookings")

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

    cursor.execute("""
        UPDATE Employees
        SET Status = N'nghỉ không phép'
        WHERE Employee_ID = ?
    """, (employee_id,))

    conn.commit()
    conn.close()

    return redirect("/staff")
if __name__ == "__main__":

  app.run(host="0.0.0.0", port=5000, debug=True)
    # return render_template("nhan_vien.html")


# app.run(host="0.0.0.0", port=5000, debug=True)
from flask import Flask, render_template, request, redirect, send_from_directory
from flask import session
from db import get_connection
from datetime import datetime
import uuid
import os

app = Flask(__name__)
app.secret_key = "abc123"

IMAGE_ROOT = os.path.join(app.root_path, "static", "10_phong")  # hoặc thư mục bạn đang chứa ảnh

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

# ================= ROUTE LẤY ẢNH TỪ THƯ MỤC STATIC =================
@app.route('/room_images/<path:filename>')
def room_images(filename):
    # Chỉ đường cho Flask tới thư mục "10_phong" nằm TRONG thư mục static
    image_dir = os.path.join(app.root_path, 'static', '10_phong')
    return send_from_directory(image_dir, filename)

# ================= LOGIN =================
@app.route("/", methods=["GET", "POST"])
def login():
    if request.method == "POST":
        user = request.form["username"]
        pw = request.form["password"]
        

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM LoginUser(?, ?)", (user, pw))
        result = cursor.fetchone()

        if result:
            session["user_id"] = result[0]
            # if not user_id:
            #     return redirect("/")
            return redirect("/dashboard")
        else:
            cursor.execute("SELECT * FROM LoginManager  (?, ?)", (user, pw))
            result_admin = cursor.fetchone()
            
            if result_admin:
                session["admin"] = {
                    "id": result_admin[0],
                    "name": result_admin[1],
                    "role": result_admin[5]
                }
                return redirect("/management")
            
    return render_template("login.html")

# ================= DASHBOARD =================
@app.route("/dashboard")
def dashboard():
    conn = get_connection()
    cursor = conn.cursor()

    user_id = session.get("user_id")

    cursor.execute("SELECT * FROM Rooms")
    rooms = cursor.fetchall()

    cursor.execute("SELECT * FROM Reviews")
    reviews = cursor.fetchall()

    cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
    user = cursor.fetchone()

    # ===== IMAGE MAP =====
    image_map = {
        "R01": "p1/p1_01.webp",
        "R02": "p2/p2_01.webp",
        "R03": "p3/p3_01.webp",
        "R04": "p4/p4_01.webp",
        "R05": "p5/p5_01.webp",
        "R06": "p6/p6_01.webp",
        "R07": "p7/p7_01.webp",
        "R08": "p8/p8_01.webp",
        "R09": "p9/p9_01.webp",
        "R10": "p10/p10_01.webp",
    }

    return render_template(
        "dashboard.html", 
        rooms=rooms, 
        reviews=reviews, 
        user=user, 
        image_map=image_map
    )


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

        cursor.execute("EXEC CreateAccount ?, ?, ?, ?, ?", (uid, name, mail, np, pw))
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
@app.route("/10_phong/<folder>/<filename>")
def serve_room_image(folder, filename):
    return send_from_directory(
        os.path.join(IMAGE_ROOT, folder),
        filename
    )

@app.route("/room_detail", methods=["GET", "POST"])
def room_detail():
    if request.method == "POST":
        room_id = request.form["room_id"]
        
        user_id = session.get("user_id")

        conn = get_connection()
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM GetRoom(?)", (room_id,))
        room = cursor.fetchone()

        cursor.execute("SELECT dbo.GetRatingRoom(?)", (room_id,))
        rating = cursor.fetchone()[0]
        
        cursor.execute("SELECT dbo.GetRoomType(?)", (room_id,))
        room_type = cursor.fetchone()[0]

        show_VIP = room_type == "VIP"
        show_Deluxe = room_type == "Deluxe"
        show_Standard = room_type not in ["Deluxe", "VIP"]

        cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
        user = cursor.fetchone()

        # ===== LẤY ẢNH TỪ FOLDER NGOÀI =====
        folder_map = {
            "R01": "p1",
            "R02": "p2",
            "R03": "p3",
            "R04": "p4",
            "R05": "p5",
            "R06": "p6",
            "R07": "p7",
            "R08": "p8",
            "R09": "p9",
            "R10": "p10",
        }

        folder = folder_map.get(room_id, "p1")
        base_path = os.path.join(IMAGE_ROOT, folder)

        images = []

        if os.path.exists(base_path):
            for file in sorted(os.listdir(base_path)):
                if file.endswith((".webp", ".jpg", ".png")):
                    images.append(f"/10_phong/{folder}/{file}")
        
        # Lấy review
        cursor.execute("SELECT * FROM GetReview(?)", (room_id,))
        reviews = cursor.fetchall()

        # Lấy amenities
        cursor.execute("SELECT * FROM Services")
        services = cursor.fetchall()

        return render_template(
            "room_detail.html", 
            room=room, 
            rating=rating,
            show_Standard=show_Standard,
            show_Deluxe=show_Deluxe,
            show_VIP=show_VIP, 
            user=user,
            images=images,
            reviews=reviews,
            services=services
        )
    return "Không có dữ liệu"
        

#===============Confirm================
@app.route("/confirm", methods=["POST"])
def confirm():
    room_id = request.form.get("room_id")
    checkin = request.form.get("checkin")
    checkout = request.form.get("checkout")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM GetRoom(?)", (room_id,))
    room = cursor.fetchone()

    # tính số đêm
    d1 = datetime.strptime(checkin, "%Y-%m-%d")
    d2 = datetime.strptime(checkout, "%Y-%m-%d")
    nights = (d2 - d1).days

    # tránh lỗi âm
    if nights <= 0:
        nights = 1

    total = nights * room[4]
    
    user_id = session.get("user_id")
    cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
    user = cursor.fetchone()

 # ===== LẤY ẢNH TỪ FOLDER NGOÀI =====
    folder_map = {
        "R01": "p1",
        "R02": "p2",
        "R03": "p3",
        "R04": "p4",
        "R05": "p5",
        "R06": "p6",
        "R07": "p7",
        "R08": "p8",
        "R09": "p9",
        "R10": "p10",
    }

    folder = folder_map.get(room_id, "p1")
    base_path = os.path.join(IMAGE_ROOT, folder)

    images = []
    
    if os.path.exists(base_path):
        for file in sorted(os.listdir(base_path)):
            if file.endswith((".webp", ".jpg", ".png")):
                images.append(f"/10_phong/{folder}/{file}")

    return render_template(
        "confirm.html",
        room=room,
        checkin=checkin,
        checkout=checkout,
        nights=nights,
        total=total,
        user=user,
        images=images
    )

#===============Previous booking================
@app.route("/booking_previous", methods=["GET", "POST"])
def booking_previous():
    user_id = session.get("user_id")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
    user = cursor.fetchone()

    cursor.execute("SELECT * FROM GetBooking(?)", (user_id,))
    bookings = cursor.fetchall()

    image_map = {
        "R01": "p1/p1_01.webp",
        "R02": "p2/p2_01.webp",
        "R03": "p3/p3_01.webp",
        "R04": "p4/p4_01.webp",
        "R05": "p5/p5_01.webp",
        "R06": "p6/p6_01.webp",
        "R07": "p7/p7_01.webp",
        "R08": "p8/p8_01.webp",
        "R09": "p9/p9_01.webp",
        "R10": "p10/p10_01.webp",
    }


    return render_template("booking_previous.html", 
                           user=user,
                           bookings=bookings,
                           image_map=image_map
                        )

#===============Reivew================
@app.route("/reviews/<booking_id>", methods=["GET", "POST"])
def reviews(booking_id):
    conn = get_connection()
    cursor = conn.cursor()

    user_id = session.get("user_id")
    
    cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
    user = cursor.fetchone()

    cursor.execute("SELECT * FROM Bookings WHERE Booking_ID = ?", (booking_id,))
    booking = cursor.fetchone()

    if request.method == "POST":
        # name = request.form.get("name")
        rating = request.form.get("rating")
        comment = request.form.get("comment")

        review_id = "REV" + str(uuid.uuid4())[:3]
        day = datetime.now().strftime("%d/%m/%Y")

        cursor.execute("EXEC CreateReview ?, ?, ?, ?, ?, ?", (review_id, user_id, booking_id, rating, comment, day))
        conn.commit()
        conn.close()

        return redirect("/dashboard")

    return render_template("reviews.html",
                            user=user,
                            booking=booking   
                        )

#===============Payment================
@app.route("/payment", methods=["GET", "POST"])
def payment():
    user_id = session.get("user_id")

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM GetUser(?)", (user_id,))
    user = cursor.fetchone()

    booking_id = "B" + str(uuid.uuid4())[:3]
    payment_id = "P" + str(uuid.uuid4())[:3]
    day = datetime.now().date()
    status = "Đã xác nhận"

    if request.method == "POST":
        # lấy dữ liệu từ confirm
        room_id = request.form.get("room_id")
        checkin = request.form.get("checkin")
        checkout = request.form.get("checkout")
        total = float(request.form.get("total"))

        # tạo ID
        booking_id = "B" + str(uuid.uuid4())[:3]
        payment_id = "P" + str(uuid.uuid4())[:3]
        day = datetime.now().strftime("%d/%m/%Y")
        status = "đang chờ xử lý"

        room_id = request.form.get("room_id")

        cursor.execute("SELECT * FROM GetRoom(?)", (room_id,))
        room = cursor.fetchone()

        return render_template("payment.html",
                               user=user,
                               booking_id=booking_id,
                               payment_id=payment_id,
                               total=total,
                               day=day,
                               status=status,
                               room_id=room_id,
                               checkin=checkin,
                               checkout=checkout,
                               room=room)

    return redirect("/dashboard")

@app.route("/cancel_booking_user/<id>")
def cancel_booking_user(id):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE Bookings
        SET Status = N'Đã hủy'
        WHERE Booking_ID = ?
    """, (id,))

    conn.commit()
    conn.close()

    return redirect("/booking_previous")

@app.route("/process_payment", methods=["POST"])
def process_payment():
    conn = get_connection()
    cursor = conn.cursor()

    booking_id = request.form.get("booking_id")
    payment_id = request.form.get("payment_id")

    total_str = request.form.get("total")
    # xoá dấu , . đ
    total_str = total_str.replace(",", "").replace(".", "").replace("đ", "").strip()
    total = float(total_str)
    
    room_id = request.form.get("room_id")
    
    checkin = datetime.strptime(request.form.get("checkin"), "%Y-%m-%d")
    checkout = datetime.strptime(request.form.get("checkout"), "%Y-%m-%d")
    booking_date = datetime.now()
    status_booking = "đã xác nhận"
    user_id = session.get("user_id")
    employee_id = "E02"

    # INSERT BOOKING
    cursor.execute("EXEC AddBooking ?, ?, ?, ?, ?, ?, ?, ?, ?", 
                   (booking_id, user_id, room_id, employee_id, booking_date, total, checkin, checkout, status_booking))

    # INSERT PAYMENT
    status_payment = "thành công"
    cursor.execute("EXEC CreatePayment ?, ?, ?, ?, ?", (payment_id, booking_id, total, booking_date, status_payment))

    conn.commit()
    conn.close()

    return redirect("/dashboard")


# ================ LOGOUT =================
@app.route("/logout")
def logout():
    session.clear()
    return redirect("/")

# ================ MANAGEMENT =================
@app.route("/management")
def tong_quan():    
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

    now = datetime.now()
    weekdays = ["thứ 2", "thứ 3", "thứ 4", "thứ 5", "thứ 6", "thứ 7", "chủ nhật"]
    current_date_vn = f"{weekdays[now.weekday()]}, {now.strftime('%d/%m/%Y')}"

    return render_template("tong_quan.html",
                            stats=stats_data,
                            recent_bookings=recent_data,
                            current_date=current_date_vn)

# ================= thông tin cá nhân =================
@app.route("/profile", methods=["GET", "POST"])
def profile():
    id = session.get("user_id")
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM GetUser(?)", (id,))
    user = cursor.fetchone()

    if request.method == "POST":
        name = request.form.get("name")
        phone = request.form.get("phone")

        cursor.execute("EXEC UpdateInforUser ?, ?, ?", (name, phone, id))
        conn.commit()

        return redirect(f"/profile/{id}")

    return render_template("profile.html", user=user)

# @app.route("/bookings")
# def bookings():
#     return render_template("dat_phong.html")

# ================= QUẢN LÝ PHÒNG =================
@app.route("/rooms")
def quan_ly_phong():
    if "admin" not in session:
        return redirect("/")

    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        # Lấy danh sách phòng
        cursor.execute("SELECT * FROM Rooms ORDER BY Room_Number")
        columns = [column[0] for column in cursor.description]
        rooms = [dict(zip(columns, row)) for row in cursor.fetchall()]
        
        # Thống kê trạng thái phòng
        stats = {
            'TatCa': len(rooms),
            'Trong': sum(1 for r in rooms if str(r.get('Status', '')).strip().lower() == 'có sẵn'),
            'DaDat': sum(1 for r in rooms if str(r.get('Status', '')).strip().lower() == 'đã đặt'),
            'DaNhan': sum(1 for r in rooms if str(r.get('Status', '')).strip().lower() == 'đã nhận'),
            'BaoTri': sum(1 for r in rooms if str(r.get('Status', '')).strip().lower() == 'bảo trì')
        }

        # --- PHẦN THÊM MỚI CHO CHỈNH SỬA ---
        # Lấy tất cả dịch vụ hiện có trong hệ thống
        cursor.execute("SELECT * FROM Services")
        cols_svc = [column[0] for column in cursor.description]
        all_services = [dict(zip(cols_svc, row)) for row in cursor.fetchall()]

        # Lấy mapping phòng và các dịch vụ phòng đó đang sở hữu
        cursor.execute("SELECT Room_ID, Service_ID FROM Rooms_Services")
        room_services_map = {}
        for row in cursor.fetchall():
            rid, sid = row[0], row[1]
            if rid not in room_services_map:
                room_services_map[rid] = []
            room_services_map[rid].append(sid)
        
        return render_template("phong.html", rooms=rooms, stats=stats, 
                               all_services=all_services, room_services_map=room_services_map)
    except Exception as e:
        print(f"Lỗi tải danh sách phòng: {e}")
        return "Lỗi hệ thống", 500
    finally:
        conn.close()
# ================= NÚT BẢO TRÌ PHÒNG =================
@app.route("/rooms/maintenance/<room_id>")
def toggle_maintenance(room_id):
    if "admin" not in session:
        return redirect("/")
        
    conn = get_connection()
    cursor = conn.cursor()
    try:
        # Gọi thủ tục SQL để đảo trạng thái phòng
        cursor.execute("EXEC sp_ToggleRoomMaintenance ?", (room_id,))
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"Lỗi khi bảo trì phòng: {e}")
    finally:
        conn.close()
        
    # Quay lại trang quản lý phòng sau khi bấm
    return redirect("/rooms")

# ================= ROUTE CẬP NHẬT PHÒNG =================
@app.route("/rooms/update", methods=["POST"])
def update_room():
    if "admin" not in session:
        return redirect("/")
        
    room_id = request.form.get("room_id")
    room_type = request.form.get("room_type")
    capacity = request.form.get("capacity")
    price = request.form.get("price")
    # Lấy mảng các Service_ID được check từ form
    selected_services = request.form.getlist("services") 

    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        # 1. Gọi Procedure cập nhật bảng Rooms
        cursor.execute("EXEC sp_UpdateRoomInfo ?, ?, ?, ?", (room_id, room_type, capacity, price))
        
        # 2. Xử lý bảng Rooms_Services (Xóa liên kết cũ, thêm liên kết mới)
        cursor.execute("DELETE FROM Rooms_Services WHERE Room_ID = ?", (room_id,))
        for svc_id in selected_services:
            cursor.execute("INSERT INTO Rooms_Services (Room_ID, Service_ID) VALUES (?, ?)", (room_id, svc_id))
        
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"Lỗi cập nhật phòng: {e}")
    finally:
        conn.close()
        
    return redirect("/rooms")

@app.route("/services")
def quan_ly_dich_vu():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Services")
    services = cursor.fetchall()

    total_services = len(services)

    conn.close()

    return render_template(
        "dich_vu.html",
        services=services,
        total_services=total_services
    )

@app.route("/services/add", methods=["POST"])
def add_service():
    sid = "S" + str(uuid.uuid4())[:5]
    name = request.form.get("name")
    description = request.form.get("description")
    price_raw = request.form.get("price") or "0"

    price_raw = price_raw.replace(".", "").replace(",", "")
    price = float(price_raw)

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
def payments():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT 
          p.Payment_ID,
          p.Booking_ID,
          p.Amount,
          p.Payment_Date,
          p.Status,
          u.Name,
          r.Room_Number
        FROM Payment p
        JOIN Bookings b ON p.Booking_ID = b.Booking_ID
        JOIN Users u ON b.User_ID = u.User_ID
        JOIN Rooms r ON b.Room_ID = r.Room_ID
    """)
    payments = cursor.fetchall()

    paid_total = 0
    pending_total = 0
    refund_total = 0

    paid_count = 0
    pending_count = 0
    refund_count = 0

    for p in payments:
        amount = p[2] or 0
        status = p[4]

        if status == "thành công":
            paid_total += amount
            paid_count += 1
        elif status == "đang chờ xử lý":
            pending_total += amount
            pending_count += 1
        elif status == "thất bại":
            refund_total += amount
            refund_count += 1

    conn.close()

    return render_template(
        "thanh_toan.html",
        payments=payments,
        paid_total=paid_total,
        pending_total=pending_total,
        refund_total=refund_total,
        paid_count=paid_count,
        pending_count=pending_count,
        refund_count=refund_count
    )

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
    # return render_template("dich_vu.html")

# @app.route("/payments")
# def quan_ly_thanh_toan():
#     return render_template("thanh_toan.html")

# ================= QUẢN LÝ HÓA ĐƠN =================
@app.route("/invoices")
def quan_ly_hoa_don():
    if "admin" not in session:
        return redirect("/")

    conn = get_connection()
    cursor = conn.cursor()
    try:
        # 1. Lấy thông số thống kê
        cursor.execute("EXEC sp_GetInvoiceStats")
        row = cursor.fetchone()
        stats = {
            'TotalInvoices': row.TotalInvoices if row else 0,
            'MonthlyRevenue': row.MonthlyRevenue if row else 0,
            'AvgPerInvoice': row.AvgPerInvoice if row else 0
        }

        # 2. Lấy danh sách hóa đơn
        cursor.execute("SELECT * FROM v_ManageInvoices ORDER BY Issued_Date DESC")
        columns = [column[0] for column in cursor.description]
        invoices = [dict(zip(columns, r)) for r in cursor.fetchall()]

        return render_template("hoa_don.html", invoices=invoices, stats=stats)
    except Exception as e:
        print(f"Lỗi tải danh sách hóa đơn: {e}")
        return "Lỗi hệ thống", 500
    finally:
        conn.close()

@app.route("/staff")
def quan_ly_nhan_vien():
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT * FROM Employees")
    employees = cursor.fetchall()

    total_employees = len(employees)

    conn.close()

    return render_template(
        "nhan_vien.html",
        employees=employees,
        total_employees=total_employees
    )

# ================= QUẢN LÝ ĐẶT PHÒNG =================
@app.route("/bookings")
def quan_ly_dat_phong():
    # Kiểm tra nếu không phải admin thì chuyển hướng về trang chủ
    if "admin" not in session:
        return redirect("/")

    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        # Lấy danh sách từ View
        cursor.execute("SELECT * FROM v_ManageBookings ORDER BY Check_In DESC")
        columns = [column[0] for column in cursor.description]
        bookings = [dict(zip(columns, row)) for row in cursor.fetchall()]
        
        # Đếm số lượng cho các tab trạng thái
        tabs_count = {
            'TatCa': len(bookings),
            'ChoXacNhan': sum(1 for b in bookings if b['Status'] == 'Chờ xác nhận'),
            'DaXacNhan': sum(1 for b in bookings if b['Status'] == 'Đã xác nhận'),
            'DangO': sum(1 for b in bookings if b['Status'] == 'Đã nhận phòng'),
            'DaTraPhong': sum(1 for b in bookings if b['Status'] == 'Đã trả phòng'),
            'DaHuy': sum(1 for b in bookings if b['Status'] == 'Đã hủy')
        }
        
        return render_template("dat_phong.html", bookings=bookings, tabs=tabs_count)
    except Exception as e:
        print(f"Lỗi tải trang đặt phòng: {e}")
        return "Lỗi hệ thống", 500
    finally:
        conn.close()
# ================= THÊM PHÒNG MỚI =================
@app.route("/rooms/add", methods=["POST"])
def add_room():
    if "admin" not in session:
        return redirect("/")
        
    conn = get_connection()
    cursor = conn.cursor()
    
    try:
        # 1. Tìm ID lớn nhất hiện tại để tính ID tiếp theo
        cursor.execute("SELECT Room_ID FROM Rooms")
        all_ids = [row[0] for row in cursor.fetchall()]
        
        numeric_ids = []
        for i in all_ids:
            # Nếu ID bắt đầu bằng 'R' (VD: R01, R10), cắt bỏ chữ R và lấy phần số
            if i.startswith('R') and i[1:].isdigit():
                numeric_ids.append(int(i[1:]))
            # Nếu ID chỉ toàn số (phòng trường hợp dữ liệu cũ)
            elif i.isdigit():
                numeric_ids.append(int(i))
                
        # Tìm số lớn nhất và cộng 1. Nếu chưa có phòng nào thì bắt đầu từ 1.
        next_id_num = max(numeric_ids) + 1 if numeric_ids else 1
        
        # Định dạng lại ID: Thêm chữ 'R' và độ dài 2 chữ số (VD: 1 -> R01, 11 -> R11)
        room_id = f"R{next_id_num:02d}"

        # 2. Lấy dữ liệu từ form
        room_number = request.form.get("room_number")
        room_type = request.form.get("room_type")
        capacity = request.form.get("capacity")
        price = request.form.get("price")
        status = "có sẵn"  # Mặc định phòng mới thêm sẽ ở trạng thái Trống
        selected_services = request.form.getlist("services")

        # 3. Thêm vào bảng Rooms
        cursor.execute("""
            INSERT INTO Rooms (Room_ID, Room_Number, Room_type, Capacity, Price_Per_Night, Status)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (room_id, room_number, room_type, capacity, price, status))
        
        # 4. Thêm dịch vụ vào bảng Rooms_Services
        for svc_id in selected_services:
            cursor.execute("INSERT INTO Rooms_Services (Room_ID, Service_ID) VALUES (?, ?)", (room_id, svc_id))
            
        conn.commit()
    except Exception as e:
        conn.rollback()
        print(f"Lỗi thêm phòng: {e}")
    finally:
        conn.close()
        
    return redirect("/rooms")

# ================= CÁC NÚT HÀNH ĐỘNG ĐẶT PHÒNG =================
@app.route("/bookings/confirm/<booking_id>")
def confirm_booking(booking_id):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("EXEC sp_ConfirmBooking ?", (booking_id,))
    conn.commit()
    conn.close()
    return redirect("/bookings")

@app.route("/bookings/checkin/<booking_id>")
def checkin_booking(booking_id):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("EXEC sp_CheckInBooking ?", (booking_id,))
    conn.commit()
    conn.close()
    return redirect("/bookings")

@app.route("/bookings/checkout/<booking_id>")
def checkout_booking(booking_id):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("EXEC sp_CheckOutBooking ?", (booking_id,))
    conn.commit()
    conn.close()
    return redirect("/bookings")

@app.route("/bookings/cancel/<booking_id>")
def cancel_booking(booking_id):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute("EXEC sp_CancelBooking ?", (booking_id,))
    conn.commit()
    conn.close()
    return redirect("/bookings")

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

    cursor.execute("""
        UPDATE Employees
        SET Status = N'nghỉ không phép'
        WHERE Employee_ID = ?
    """, (employee_id,))

    conn.commit()
    conn.close()

    return redirect("/staff")
if __name__ == "__main__":

  app.run(host="0.0.0.0", port=5000, debug=True)
    # return render_template("nhan_vien.html")


# app.run(host="0.0.0.0", port=5000, debug=True)

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
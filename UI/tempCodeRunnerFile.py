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
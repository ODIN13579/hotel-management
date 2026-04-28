-- View lấy thông tin đặt phòng đầy đủ để hiển thị
CREATE or alter VIEW v_DashboardRecentBookings AS
SELECT TOP 10 
    b.Booking_ID, 
    u.Name AS Customer_Name, 
    r.Room_Number, 
    b.Check_In, 
    b.Status
FROM Bookings b
JOIN Users u ON b.User_ID = u.User_ID
JOIN Rooms r ON b.Room_ID = r.Room_ID
ORDER BY b.Booking_Date DESC; -- Luôn đưa đơn mới nhất lên đầu
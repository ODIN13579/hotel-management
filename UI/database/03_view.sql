-- View lấy thông tin đặt phòng 10 đơn gần nhất để hiển thị (chỉ lấy đơn đang hoạt động)
CREATE OR ALTER VIEW v_DashboardRecentBookings AS
SELECT TOP 10 
    b.Booking_ID, 
    u.Name AS Customer_Name, 
    r.Room_Number, 
    b.Check_In, 
    b.Status
FROM Bookings b
JOIN Users u ON b.User_ID = u.User_ID
JOIN Rooms r ON b.Room_ID = r.Room_ID
WHERE b.Status NOT IN (N'Đã trả phòng', N'Đã hủy') -- Lọc bỏ các phòng đã xong hoặc bị hủy
ORDER BY b.Booking_Date DESC; 


GO
-- VIEW: LẤY TOÀN BỘ DANH SÁCH ĐẶT PHÒNG
CREATE OR ALTER VIEW v_ManageBookings AS
SELECT 
    b.Booking_ID, 
    u.Name AS Customer_Name, 
    u.Phone AS Customer_Phone,
    r.Room_type,
    r.Room_Number,
    b.Check_In, 
    b.Check_Out,
    ISNULL(b.Room_deposit, 0) AS Room_deposit,
    b.Status
FROM Bookings b
JOIN Users u ON b.User_ID = u.User_ID
JOIN Rooms r ON b.Room_ID = r.Room_ID;


GO
-- VIEW: THỐNG KÊ SỐ LƯỢNG PHÒNG THEO TRẠNG THÁI
CREATE OR ALTER VIEW v_RoomStatusStats AS
SELECT 
    COUNT(*) AS TatCa,
    SUM(CASE WHEN Status = N'Có sẵn' THEN 1 ELSE 0 END) AS Trong,
    SUM(CASE WHEN Status = N'Đã đặt' THEN 1 ELSE 0 END) AS DaDat,
    SUM(CASE WHEN Status = N'Đã nhận' THEN 1 ELSE 0 END) AS DaNhan,
    SUM(CASE WHEN Status = N'Bảo trì' THEN 1 ELSE 0 END) AS BaoTri
FROM Rooms;
GO

-- 1. View lấy danh sách hóa đơn kèm thông tin khách và phòng
CREATE OR ALTER VIEW v_ManageInvoices AS
SELECT 
    i.Invoice_ID,
    u.Name AS Customer_Name,
    u.Phone AS Customer_Phone,
    u.Email AS Customer_Email,
    b.Booking_ID,
    r.Room_type,
    r.Room_Number,
    b.Check_In,
    b.Check_Out,
    -- Tính số đêm (nếu checkin checkout cùng ngày thì tính là 1)
    CASE WHEN DATEDIFF(day, b.Check_In, b.Check_Out) = 0 THEN 1 
         ELSE DATEDIFF(day, b.Check_In, b.Check_Out) END AS Nights,
    ISNULL(b.Room_deposit, 0) AS Room_deposit,
    i.Total_Amount,
    i.Issued_Date
FROM Invoices i
JOIN Users u ON i.User_ID = u.User_ID
JOIN Bookings b ON i.Booking_ID = b.Booking_ID
JOIN Rooms r ON b.Room_ID = r.Room_ID;
GO
USE [Hotel_Manage]
GO

-- 1. Danh sách dịch vụ
CREATE VIEW vw_services_list AS
SELECT Service_ID, Name, Description, Price
FROM Services;
GO

-- 2. Chi tiết hóa đơn
CREATE VIEW vw_invoice_detail AS
SELECT 
    i.Invoice_ID,
    u.Name AS Customer_Name,
    b.Booking_ID,
    r.Room_Number,
    i.Total_Amount,
    i.Issued_Date
FROM Invoices i
JOIN Users u ON i.User_ID = u.User_ID
JOIN Bookings b ON i.Booking_ID = b.Booking_ID
JOIN Rooms r ON b.Room_ID = r.Room_ID;
GO

-- 3. Review
CREATE VIEW VW_Reviews AS
SELECT 
    R.Review_ID,
    U.Name AS User_Name,
    B.Booking_ID,
    R.Rating,
    R.Comment
FROM Reviews R
JOIN Users U ON R.User_ID = U.User_ID
JOIN Bookings B ON R.Booking_ID = B.Booking_ID;
GO

-- 4. Notification
CREATE VIEW VW_Notifications AS
SELECT 
    N.Notification_ID,
    U.Name,
    N.Message,
    N.Sent_Date
FROM Notifications N
JOIN Users U ON N.User_ID = U.User_ID;
GO

-- 5. Nhân viên
CREATE VIEW VW_Employees AS
SELECT Employee_ID, Name, Email, Phone, Role, Status
FROM Employees;
GO

-- 6. Báo cáo booking + doanh thu
CREATE VIEW vw_booking_report AS
SELECT 
    b.Booking_ID,
    b.User_ID,
    b.Room_ID,
    b.Employee_ID,
    b.Booking_Date,
    b.Check_In,
    b.Check_Out,
    b.Status AS Booking_Status,
    ISNULL(b.Room_Deposit,0) + ISNULL(p.Amount,0) AS Revenue
FROM Bookings b
LEFT JOIN Payment p ON p.Booking_ID = b.Booking_ID;
GO
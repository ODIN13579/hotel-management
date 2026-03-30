-- tạo các view ở đây
use hotel_management;
-- xóa các view nếu đã tồn tại

-- viet code tạo view ở đây

-- chức năng 4:
CREATE VIEW vw_services_list AS
SELECT 
    Service_ID,
    Name,
    Description,
    Price
FROM Services;

-- chức năng 5:
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

-- chức năng 7
CREATE VIEW VW_Reviews
AS
SELECT 
    R.Review_ID,
    U.Name AS User_Name,
    B.Booking_ID,
    R.Rating,
    R.Comment
FROM Reviews R
JOIN Users U ON R.User_ID = U.User_ID
JOIN Bookings B ON R.Booking_ID = B.Booking_ID;
-- chức năng 8
CREATE VIEW VW_Notifications
AS
SELECT 
    N.Notification_ID,
    U.Name,
    N.Message,
    N.Date
FROM Notifications N
JOIN Users U ON N.User_ID = U.User_ID;

-- chức năng 9
CREATE VIEW VW_Employees
AS
SELECT 
    Employee_ID,
    Name,
    Email,
    Phone,
    Role,
    Status
FROM Employees;

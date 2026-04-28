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
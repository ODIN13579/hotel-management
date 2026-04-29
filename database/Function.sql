

-- 1. Tính tiền phòng
CREATE FUNCTION calculate_total(@booking_id VARCHAR(50))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @total DECIMAL(18,2)

    SELECT @total = DATEDIFF(DAY, b.Check_In, b.Check_Out) * r.Price_Per_Night
    FROM Bookings b
    JOIN Rooms r ON b.Room_ID = r.Room_ID
    WHERE b.Booking_ID = @booking_id

    RETURN ISNULL(@total,0)
END
GO

-- 2. Tính tổng revenue
CREATE FUNCTION fn_booking_revenue(@booking_id VARCHAR(50))
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @total DECIMAL(18,2)

    SELECT @total = ISNULL(b.Room_Deposit,0) + ISNULL(p.Amount,0)
    FROM Bookings b
    LEFT JOIN Payment p ON p.Booking_ID = b.Booking_ID
    WHERE b.Booking_ID = @booking_id

    RETURN ISNULL(@total,0)
END
GO

-- 3. Lấy rating phòng
CREATE FUNCTION GetRatingRoom (@room_id VARCHAR(50))
RETURNS FLOAT
AS
BEGIN
    DECLARE @rating FLOAT

    SELECT @rating = AVG(R.Rating)
    FROM Reviews R
    JOIN Bookings B ON R.Booking_ID = B.Booking_ID
    WHERE B.Room_ID = @room_id

    RETURN @rating
END
GO

-- 4. Lấy loại phòng
CREATE FUNCTION GetRoomType(@room_id VARCHAR(50))
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @type VARCHAR(50)

    SELECT @type = Room_Type FROM Rooms WHERE Room_ID = @room_id

    RETURN @type
END
GO

-- 5. Lấy đánh giá của phòng
CREATE FUNCTION GetRatingRoom (@room_id VARCHAR(50))
RETURNS FLOAT
AS
BEGIN
    DECLARE @rating FLOAT

    SELECT @rating = AVG(Rw.Rating)
    FROM Reviews Rw
    JOIN Bookings B ON Rw.Booking_ID = B.Booking_ID
    WHERE B.Room_ID = @room_id

    RETURN @rating
END
GO

-- 6. Lấy loại phòng
CREATE FUNCTION GetRoomType(@room_id VARCHAR(50))
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @room_type VARCHAR(50)
    SELECT @room_type = R.Room_Type FROM Rooms R WHERE R.Room_ID = @room_id

    RETURN @room_type
END
GO

-- 7. Đăng nhập User
CREATE FUNCTION LoginUser(@email VARCHAR(50), @pass VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Users U 
    WHERE U.Email = @email AND U.Password = @pass
)
GO


-- 8. Đăng nhập Manager
CREATE FUNCTION LoginManager(@email VARCHAR(50), @pass VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Employees E 
    WHERE E.Email = @email AND E.Password = @pass
)
GO

-- 8. Lấy thông tin User
CREATE FUNCTION GetUser(@user_id VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Users U 
    WHERE U.User_ID = @user_id
)
GO

-- 9. Lấy thông tin phòng
CREATE FUNCTION GetRoom(@room_id VARCHAR(50))
RETURNS TABLE
AS
RETURN
(
    SELECT * FROM Rooms R 
    WHERE R.Room_ID = @room_id
)
GO

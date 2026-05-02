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

-- 10. Lấy Booking
CREATE FUNCTION GetBooking(@user_id VARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT * FROM Bookings B 
    WHERE B.User_ID = @user_id
)
GO
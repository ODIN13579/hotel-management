

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
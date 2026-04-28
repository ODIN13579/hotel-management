-- 1. Ghi nhận thanh toán
CREATE PROCEDURE sp_record_transaction
    @booking_id VARCHAR(50),
    @user_id VARCHAR(50),
    @method VARCHAR(50)
AS
BEGIN
    DECLARE @invoice_id VARCHAR(50)

    SET @invoice_id = 'I' + RIGHT('0000'+CAST(FLOOR(RAND()*10000) AS VARCHAR),4)

    INSERT INTO Invoices(Invoice_ID, Booking_ID, User_ID, Issued_Date)
    VALUES(@invoice_id,@booking_id,@user_id,GETDATE())

    INSERT INTO Payment
    VALUES(
        'P' + RIGHT('0000'+CAST(FLOOR(RAND()*10000) AS VARCHAR),4),
        @booking_id,
        dbo.calculate_total(@booking_id),
        GETDATE(),
        @method,
        'successful'
    )
END
GO

-- 2. Phân công booking
CREATE PROCEDURE sp_assign_booking
    @booking_id VARCHAR(50),
    @employee_id VARCHAR(50)
AS
BEGIN
    UPDATE Bookings
    SET Employee_ID = @employee_id,
        Status = 'confirmed'
    WHERE Booking_ID = @booking_id

    UPDATE Rooms
    SET Status = 'booked'
    WHERE Room_ID = (SELECT Room_ID FROM Bookings WHERE Booking_ID = @booking_id)
END
GO

-- 3. Báo cáo doanh thu tháng
CREATE PROCEDURE sp_report_revenue_month
AS
BEGIN
    SELECT 
        YEAR(Booking_Date) AS Year,
        MONTH(Booking_Date) AS Month,
        COUNT(*) AS Total_Booking,
        SUM(Revenue) AS Revenue
    FROM vw_booking_report
    GROUP BY YEAR(Booking_Date), MONTH(Booking_Date)
END
GO

-- 4. Tạo tài khoản
CREATE PROCEDURE CreateAccount
    @id VARCHAR(50),
    @name NVARCHAR(100),
    @email VARCHAR(100),
    @phone VARCHAR(50),
    @pass VARCHAR(100)
AS
BEGIN
    INSERT INTO Users VALUES(@id,@name,@email,@phone,@pass)
END
GO

-- 5. Cập nhật user
CREATE PROCEDURE UpdateInformation
    @id VARCHAR(50),
    @name NVARCHAR(100),
    @email VARCHAR(100),
    @phone VARCHAR(50),
    @pass VARCHAR(100)
AS
BEGIN
    UPDATE Users
    SET Name=@name, Email=@email, Phone=@phone, Password=@pass
    WHERE User_ID=@id
END
GO
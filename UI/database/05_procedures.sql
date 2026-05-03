-- Lấy các thông số tổng hợp cho trang Dashboard (Tổng quan)
CREATE OR ALTER PROCEDURE sp_GetDashboardSummary
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. CÁC BIẾN THỐNG KÊ CHÍNH
    DECLARE @TotalRooms INT = (SELECT COUNT(*) FROM Rooms);
    
    DECLARE @TodayBookings INT = (
        SELECT COUNT(*) FROM Bookings 
        WHERE CAST(Booking_Date AS DATE) = CAST(GETDATE() AS DATE)
    );

    -- Doanh thu tháng: Tổng tiền từ các hóa đơn trong tháng này
    DECLARE @MonthlyRevenue DECIMAL(18, 2) = (
        SELECT ISNULL(SUM(Total_Amount), 0) 
        FROM Invoices 
        WHERE MONTH(Issued_Date) = MONTH(GETDATE()) 
          AND YEAR(Issued_Date) = YEAR(GETDATE())
    );

    -- 2. CÁC BIẾN TRẠNG THÁI PHÒNG (Lấy trực tiếp từ bảng Rooms)
    DECLARE @Trong INT = (SELECT COUNT(*) FROM Rooms WHERE Status = N'Có sẵn');
    DECLARE @DaDat INT = (SELECT COUNT(*) FROM Rooms WHERE Status = N'Đã đặt');
    DECLARE @DaNhan INT = (SELECT COUNT(*) FROM Rooms WHERE Status = N'Đã nhận');
    DECLARE @BaoTri INT = (SELECT COUNT(*) FROM Rooms WHERE Status = N'Bảo trì');

    -- 3. TRẢ KẾT QUẢ
    SELECT 
        @TotalRooms AS TotalRooms, 
        @TodayBookings AS TodayBookings, 
        @MonthlyRevenue AS MonthlyRevenue,
        @Trong AS Trong,
        @DaDat AS DaDat,
        @DaNhan AS DaNhan,
        @BaoTri AS BaoTri;
END;
GO

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
        'Thành công'
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
        Status = 'Đã nhận phòng'
    WHERE Booking_ID = @booking_id

    UPDATE Rooms
    SET Status = 'Đã đặt'
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

-- 6. Đặt phòng
CREATE PROCEDURE AddBooking (
	@booking_id VARCHAR(50),
	@user_id VARCHAR(50),
    @room_id VARCHAR(50),
    @employee_id VARCHAR(50),
    @booking_date DATETIME,
    @room_deposit DECIMAL(18,2),
    @checkin DATETIME,
    @checkout DATETIME,
    @status NVARCHAR(50)
)
AS
BEGIN	
    INSERT INTO [dbo].[Bookings]
               ([Booking_ID]
               ,[User_ID]
               ,[Room_ID]
               ,[Employee_ID]
               ,[Booking_Date]
               ,[Room_deposit]
               ,[Check_In]
               ,[Check_Out]
               ,[Status])
         VALUES
               (@booking_id
               ,@user_id
               ,@room_id
               ,@employee_id
               ,@booking_date
               ,@room_deposit
               ,@checkin
               ,@checkout
               ,@status)

END
GO

-- 7. Thêm tài khoản user
CREATE PROCEDURE InsertNewUser(
    @user_id VARCHAR(50),
    @username VARCHAR(50),
    @email VARCHAR(50),
    @phone VARCHAR(50),
    @pass VARCHAR(50)
)
AS
BEGIN


    INSERT INTO [dbo].[Users]
               ([User_ID]
               ,[Name]
               ,[Email]
               ,[Phone]
               ,[Password])
         VALUES
               (@user_id
               , @username
               , @email
               , @phone
               , @pass)
END
GO

-- 8. Cập nhật thông tin User
CREATE PROCEDURE UpdateInforUser(
    @user_id VARCHAR(50),
    @new_name VARCHAR(50),
    @new_phone VARCHAR(50)
)
AS
BEGIN
    UPDATE Users 
    SET Name = @new_name, Phone = @new_phone
    WHERE User_ID = @user_id
END
GO

-- 9. "Xác nhận" (Chỉ cập nhật Bookings, bảng Rooms để Trigger tự lo)
CREATE OR ALTER PROCEDURE sp_ConfirmBooking
    @BookingID VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Bookings SET Status = N'Đã xác nhận' WHERE Booking_ID = @BookingID;
END;
GO

-- 10. "Nhận phòng" (Chỉ cập nhật Bookings, bảng Rooms để Trigger tự lo)
CREATE OR ALTER PROCEDURE sp_CheckInBooking
    @BookingID VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Bookings SET Status = N'Đã nhận phòng' WHERE Booking_ID = @BookingID;
END;
GO

-- 11. "Trả phòng" (Chỉ cập nhật Bookings, bảng Rooms để Trigger tự lo)
CREATE OR ALTER PROCEDURE sp_CheckOutBooking
    @BookingID VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Bookings SET Status = N'Đã trả phòng' WHERE Booking_ID = @BookingID;
END;
GO

-- 12."Hủy" (Chỉ cập nhật Bookings, bảng Rooms để Trigger tự lo)
CREATE OR ALTER PROCEDURE sp_CancelBooking
    @BookingID VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Bookings SET Status = N'Đã hủy' WHERE Booking_ID = @BookingID;
END;
GO

-- 13. Cập nhật thông tin cơ bản của phòng
CREATE OR ALTER PROCEDURE sp_UpdateRoomInfo
    @RoomID VARCHAR(50),
    @RoomType NVARCHAR(100),
    @Capacity INT,
    @Price DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Rooms
    SET Room_type = @RoomType,
        Capacity = @Capacity,
        Price_Per_Night = @Price
    WHERE Room_ID = @RoomID;
END;
GO

-- 14. Procedure tính thống kê Hóa đơn (theo tháng hiện tại)
CREATE OR ALTER PROCEDURE sp_GetInvoiceStats
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TotalInvoices INT = (SELECT COUNT(*) FROM Invoices);
    
    DECLARE @MonthlyRevenue DECIMAL(18,2) = (
        SELECT ISNULL(SUM(Total_Amount), 0) 
        FROM Invoices 
        WHERE MONTH(Issued_Date) = MONTH(GETDATE()) 
          AND YEAR(Issued_Date) = YEAR(GETDATE())
    );

    DECLARE @MonthlyInvoices INT = (
        SELECT COUNT(*) FROM Invoices 
        WHERE MONTH(Issued_Date) = MONTH(GETDATE()) 
          AND YEAR(Issued_Date) = YEAR(GETDATE())
    );

    DECLARE @AvgPerInvoice DECIMAL(18,2) = 0;
    IF @MonthlyInvoices > 0
        SET @AvgPerInvoice = @MonthlyRevenue / @MonthlyInvoices;

    SELECT 
        @TotalInvoices AS TotalInvoices,
        @MonthlyRevenue AS MonthlyRevenue,
        @AvgPerInvoice AS AvgPerInvoice;
END;
GO
-- 15 Procedure chuyển trạng thái phòng giữa "có sẵn" và "bảo trì"
CREATE OR ALTER PROCEDURE sp_ToggleRoomMaintenance
    @RoomID VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @CurrentStatus NVARCHAR(50);
    
    -- Lấy trạng thái hiện tại của phòng
    SELECT @CurrentStatus = Status FROM Rooms WHERE Room_ID = @RoomID;
    
    -- Nếu đang "có sẵn" -> Đổi thành "bảo trì"
    IF @CurrentStatus = N'Có sẵn'
    BEGIN
        UPDATE Rooms SET Status = N'Bảo trì' WHERE Room_ID = @RoomID;
    END
    -- Nếu đang "bảo trì" -> Đổi lại thành "có sẵn"
    ELSE IF @CurrentStatus = N'Bảo trì'
    BEGIN
        UPDATE Rooms SET Status = N'Có sẵn' WHERE Room_ID = @RoomID;
    END
    -- Bỏ qua nếu phòng "đã đặt" hoặc "đã nhận" để tránh lỗi dữ liệu đặt phòng
END;
GO


-- 16 Tạo thanh toán
CREATE PROCEDURE CreatePayment (
    @payment_id VARCHAR(50),
	@booking_id VARCHAR(50),
	@amount DECIMAL(18,2),  
    @payment_date DATETIME,
    @status NVARCHAR(50)
)
AS
BEGIN	
    INSERT INTO [dbo].[Payment]
               ([Payment_ID]
               ,[Booking_ID]
               ,[Amount]
               ,[Payment_Date]
               ,[Payment_Method]
               ,[Status])
         VALUES
               (@payment_id
               ,@booking_id
               ,@amount
               ,@payment_date
               ,N'Chuyển khoản'
               ,@status)
END
GO

-- 17 Tạo đánh giá
CREATE PROCEDURE CreateReview(
    @review_id VARCHAR(50),
    @user_id VARCHAR(50),
    @booking VARCHAR(50),
    @rating INT,
    @comment NVARCHAR(255),
    @createAt DATETIME
)
AS
BEGIN
    INSERT INTO [dbo].[Reviews]
               ([Review_ID]
               ,[User_ID]
               ,[Booking_ID]
               ,[Rating]
               ,[Comment]
               ,[Created_At])
         VALUES
               (@review_id
               ,@user_id
               ,@booking
               ,@rating
               ,@comment
               ,@createAt)
END
GO

-- 18. Lấy bảng room có rating
CREATE PROCEDURE RoomHaveRating
AS
BEGIN
    SELECT *, dbo.AvgRatingRoom(R.Room_ID) AS Rating
    FROM Rooms R
END
GO

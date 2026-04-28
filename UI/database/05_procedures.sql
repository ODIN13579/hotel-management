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
    DECLARE @Trong INT = (SELECT COUNT(*) FROM Rooms WHERE Status = N'có sẵn');
    DECLARE @DaDat INT = (SELECT COUNT(*) FROM Rooms WHERE Status = N'đã đặt');
    DECLARE @DaNhan INT = (SELECT COUNT(*) FROM Rooms WHERE Status = N'đã nhận');
    DECLARE @BaoTri INT = (SELECT COUNT(*) FROM Rooms WHERE Status = N'bảo trì');

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


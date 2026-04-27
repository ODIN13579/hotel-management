-- Lấy các thông số tổng hợp cho trang Dashboard (Tổng quan)
CREATE PROCEDURE sp_GetDashboardSummary
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @TotalRooms INT;
    DECLARE @TodayBookings INT;
    DECLARE @MonthlyRevenue DECIMAL(18, 2);

    SELECT @TotalRooms = COUNT(*) FROM Rooms;

    SELECT @TodayBookings = COUNT(*) 
    FROM Bookings 
    WHERE CAST(Booking_Date AS DATE) = CAST(GETDATE() AS DATE);

    SELECT @MonthlyRevenue = ISNULL(SUM(Total_Amount), 0) 
    FROM Invoices 
    WHERE MONTH(Issued_Date) = MONTH(GETDATE()) 
      AND YEAR(Issued_Date) = YEAR(GETDATE());

    SELECT 
        @TotalRooms AS TotalRooms, 
        @TodayBookings AS TodayBookings, 
        @MonthlyRevenue AS MonthlyRevenue;
END;
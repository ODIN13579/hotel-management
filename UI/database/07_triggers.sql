-- 1. TRIGGER: Tự động xuất hóa đơn khi khách Check-out
CREATE OR ALTER TRIGGER trg_AutoCreateInvoice
ON Bookings
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    -- Nếu trạng thái được update thành 'Đã trả phòng'
    IF UPDATE(Status)
    BEGIN
        INSERT INTO Invoices (Invoice_ID, User_ID, Booking_ID, Total_Amount, Issued_Date)
        SELECT 
            'INV' + RIGHT('00000' + CAST(ABS(CHECKSUM(NEWID())) % 100000 AS VARCHAR), 5), -- Tạo mã INV ngẫu nhiên
            i.User_ID,
            i.Booking_ID,
            -- Tính tổng tiền = Số đêm * Giá phòng
            (CASE WHEN DATEDIFF(day, i.Check_In, i.Check_Out) = 0 THEN 1 ELSE DATEDIFF(day, i.Check_In, i.Check_Out) END) * r.Price_Per_Night, 
            GETDATE()
        FROM inserted i
        JOIN Rooms r ON i.Room_ID = r.Room_ID
        WHERE i.Status = N'Đã trả phòng'
          -- Đảm bảo không tạo trùng hóa đơn nếu đã có
          AND NOT EXISTS (SELECT 1 FROM Invoices inv WHERE inv.Booking_ID = i.Booking_ID);
    END
END;
GO
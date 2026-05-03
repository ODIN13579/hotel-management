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

-- TRIGGER: TỰ ĐỘNG ĐỒNG BỘ TRẠNG THÁI PHÒNG KHI ĐẶT PHÒNG THAY ĐỔI
CREATE OR ALTER TRIGGER trg_AutoSyncRoomStatus
ON Bookings
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Status)
    BEGIN
        -- 1. Nếu khách Trả phòng hoặc Hủy -> Trả phòng về 'có sẵn' (Trống)
        UPDATE r
        SET r.Status = N'Có sẵn'
        FROM Rooms r
        JOIN inserted i ON r.Room_ID = i.Room_ID
        WHERE i.Status IN (N'Đã trả phòng', N'Đã hủy');

        -- 2. Nếu đơn Đã xác nhận -> Chuyển phòng thành 'đã đặt'
        UPDATE r
        SET r.Status = N'Đã đặt'
        FROM Rooms r
        JOIN inserted i ON r.Room_ID = i.Room_ID
        WHERE i.Status = N'Đã xác nhận';

        -- 3. Nếu khách Đã nhận phòng -> Chuyển phòng thành 'đã nhận'
        UPDATE r
        SET r.Status = N'Đã nhận'
        FROM Rooms r
        JOIN inserted i ON r.Room_ID = i.Room_ID
        WHERE i.Status = N'Đã nhận phòng';
    END
END;
GO
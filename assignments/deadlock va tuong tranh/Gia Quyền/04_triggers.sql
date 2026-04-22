-- Trigger tu dong hoa cap nhat trang thai phong
CREATE TRIGGER trg_TuDongCapNhatTrangThaiPhong
ON Bookings
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Khách đặt cọc/Xác nhận đặt phòng -> Phòng chuyển sang 'Đã đặt (cọc)'
    UPDATE r SET r.Status = N'Đã đặt (cọc)'
    FROM Rooms r INNER JOIN inserted i ON r.Room_ID = i.Room_ID
    WHERE i.Status = N'Đã xác nhận';

    -- 2. Khách trả phòng hoặc Hủy -> Phòng quay về 'Trống'
    UPDATE r SET r.Status = N'Trống'
    FROM Rooms r INNER JOIN inserted i ON r.Room_ID = i.Room_ID
    WHERE i.Status IN (N'Đã trả phòng', N'Đã hủy');

    -- 3. Nếu bạn có thêm trạng thái 'Đã nhận phòng' ở bảng Bookings
    UPDATE r SET r.Status = N'Đã nhận'
    FROM Rooms r INNER JOIN inserted i ON r.Room_ID = i.Room_ID
    WHERE i.Status = N'Đã nhận phòng';
END;
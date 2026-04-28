USE hotel_management;
GO

-- Xóa dữ liệu cũ nếu có
DELETE FROM Rooms;

-- Thêm 3 phòng mẫu để test
INSERT INTO Rooms (Room_ID, Room_Number, Room_type, Capacity, Price_Per_Night, Status)
VALUES 
('R101', '101', N'Standard', 2, 500000, N'Trống'),
('R102', '102', N'VIP', 2, 1500000, N'Trống'),
('R103', '103', N'Family', 4, 2000000, N'Trống');
GO

-- SESSION 1: 
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRAN;

-- Lần 1: Đếm danh sách phòng trống (Sẽ ra 3 phòng: 101, 102, 103)
SELECT Room_ID, Status FROM Rooms WHERE Status = N'Trống';

-- Chờ 5 giây để chuẩn bị in báo cáo
WAITFOR DELAY '00:00:05';

-- Lần 2: Đếm lại phòng trống để in. Tự nhiên thấy còn có 2 phòng (Mất R101)
-- R101 biến mất như một "bóng ma"
SELECT Room_ID, Status FROM Rooms WHERE Status = N'Trống';

COMMIT TRAN;

-- SESSION 2: Có khách đến thuê R101
BEGIN TRAN;

-- Lễ tân B đổi trạng thái làm thay đổi số lượng kết quả của Session 1 đang chạy
UPDATE Rooms SET Status = N'Đã nhận' WHERE Room_ID = 'R101';

COMMIT TRAN;
PRINT N'Session 2 đã cho thuê R101';
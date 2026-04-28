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

-- SESSION 1: Cần cập nhật phòng 101 rồi đến 102
BEGIN TRAN;

-- Bước 1: Khóa và cập nhật R101
UPDATE Rooms SET Status = N'Bảo trì' WHERE Room_ID = 'R101';
PRINT N'S1 đã giữ khóa R101';

WAITFOR DELAY '00:00:03';

-- Bước 2: Cố gắng khóa và cập nhật R102 (Sẽ bị treo vì S2 đang giữ R102)
UPDATE Rooms SET Status = N'Bảo trì' WHERE Room_ID = 'R102';
PRINT N'S1 đã hoàn tất R102';

COMMIT TRAN;

-- SESSION 2: Cần cập nhật phòng 102 rồi đến 101
BEGIN TRAN;

-- Bước 1: Khóa và cập nhật R102
UPDATE Rooms SET Status = N'Đã nhận' WHERE Room_ID = 'R102';
PRINT N'S2 đã giữ khóa R102';

-- Đợi 3 giây
WAITFOR DELAY '00:00:03';

-- Bước 2: Cố gắng khóa và cập nhật R101 (Sẽ bị treo vì S1 đang giữ R101)
-- DẪN ĐẾN DEADLOCK
UPDATE Rooms SET Status = N'Đã nhận' WHERE Room_ID = 'R101';
PRINT N'S2 đã hoàn tất R101';

COMMIT TRAN;
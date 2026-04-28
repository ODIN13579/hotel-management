USE hotel_management;
GO
-- Một giao dịch cần đọc trạng thái phòng R103 hai lần để xử lý nghiệp vụ, 
-- nhưng ở giữa 2 lần đọc, một người khác đã sửa trạng thái đó.

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

-- Đọc lần 1: Thấy phòng R103 đang 'Trống'
SELECT Room_ID, Status FROM Rooms WHERE Room_ID = 'R103';

-- Quản lý đi uống nước mất 5 giây
WAITFOR DELAY '00:00:05'; 

-- Đọc lần 2: Trạng thái đột nhiên biến thành 'Bảo trì'
SELECT Room_ID, Status  FROM Rooms WHERE Room_ID = 'R103';

COMMIT TRAN;

-- SESSION 2: Tranh thủ lúc quản lý đi vắng, nhân viên vào khóa phòng bảo trì
BEGIN TRAN;
UPDATE Rooms SET Status = N'Bảo trì' WHERE Room_ID = 'R103';
COMMIT TRAN;

PRINT N'Session 2 đã cập nhật thành công';
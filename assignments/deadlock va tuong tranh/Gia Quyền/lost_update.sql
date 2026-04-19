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

-- SESSION 1: Lễ tân A muốn đổi phòng R101 thành 'Đã nhận'
-- đọc trạng thái lên trước
DECLARE @CurrentStatus NVARCHAR(50);
SELECT @CurrentStatus = Status FROM Rooms WHERE Room_ID = 'R101';

-- Lễ tân A tốn 5 giây để điền thông tin khách hàng trên giao diện App
WAITFOR DELAY '00:00:05'; 

-- Lễ tân A bấm "Lưu". Cập nhật đè lên database mà không kiểm tra lại
UPDATE Rooms 
SET Status = N'Đã nhận' 
WHERE Room_ID = 'R101';

PRINT N'Session 1 đã cập nhật R101 thành Đã nhận';

-- SESSION 2: Nhân viên B muốn đổi phòng R101 thành 'Bảo trì'
-- Nhân viên B cũng lấy trạng thái cùng lúc với A và thấy là 'Trống'
DECLARE @CurrentStatus NVARCHAR(50);
SELECT @CurrentStatus = Status FROM Rooms WHERE Room_ID = 'R101';

-- Nhân viên B thao tác nhanh hơn, bấm lưu ngay lập tức
UPDATE Rooms 
SET Status = N'Bảo trì' 
WHERE Room_ID = 'R101';

PRINT N'Session 2 đã cập nhật R101 thành Bảo trì';

-- KẾT QUẢ: 5 giây sau, lệnh UPDATE của Session 1 chạy và đè bẹp kết quả của Session 2.
-- Dữ liệu 'Bảo trì' bị mất hoàn toàn (Lost Update).
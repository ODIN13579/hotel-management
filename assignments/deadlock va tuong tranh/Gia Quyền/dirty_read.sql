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


-- SESSION 1: Lễ tân A thực hiện check-in nhưng đang chờ thanh toán 
BEGIN TRAN;

-- Đổi trạng thái phòng nhưng CHƯA COMMIT
UPDATE Rooms SET Status = N'Đã nhận' WHERE Room_ID = 'R102';

-- Chờ thanh toán thẻ 5 giây
WAITFOR DELAY '00:00:05'; 

-- Quẹt thẻ thất bại, khách không thuê nữa -> Hủy bỏ giao dịch (Trở về 'Trống')
ROLLBACK TRAN; 

PRINT N'Session 1 đã Rollback. R102 thực chất vẫn Trống.';


-- SESSION 2: Quản lý xem báo cáo. Muốn biết tình trạng phòng R102 nên chạy truy vấn sau:
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRAN;

-- Câu lệnh này sẽ đọc được chữ 'Đã nhận' từ Session 1 dù Session 1 chưa lưu chính thức
SELECT Room_ID, Status AS [Trạng thái ảo (Dirty Read)] -- Đọc được dữ liệu chưa commit của Session 1
FROM Rooms 
WHERE Room_ID = 'R102';

COMMIT TRAN;
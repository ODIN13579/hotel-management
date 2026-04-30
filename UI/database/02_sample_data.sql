-- 1. Thêm dữ liệu Người dùng
INSERT INTO Users (User_ID, Name, Email, Phone, Password) VALUES
('U01', N'Nguyễn Văn An', 'an.nguyen@gmail.com', '0901234567', 'hashed_pw_1'),
('U02', N'Trần Thị Bình', 'binh.tran@gmail.com', '0912345678', 'hashed_pw_2'),
('U03', N'Lê Hoàng Cường', 'cuong.le@gmail.com', '0923456789', 'hashed_pw_3'),
('U04', N'Phạm Thu Dung', 'dung.pham@gmail.com', '0934567890', 'hashed_pw_4');

-- 2. Thêm dữ liệu Nhân viên
INSERT INTO Employees (Employee_ID, Name, Email, Phone, Password, Role, Status) VALUES
('E01', N'Vũ Quản Lý', 'manager@hotel.com', '0801111111', 'hash1', N'Quản lý', N'Đang làm việc'),
('E02', N'Đặng Lễ Tân', 'reception1@hotel.com', '0802222222', 'hash2', N'Lễ tân', N'Đang làm việc'),
('E03', N'Ngô Phục Vụ', 'service1@hotel.com', '0803333333', 'hash3', N'Phục vụ phòng', N'Nghỉ phép'),
('E04', N'Bùi Bảo Vệ', 'security1@hotel.com', '0804444444', 'hash4', N'Bảo vệ', N'Nghỉ không phép');

-- 3. Thêm dữ liệu Dịch vụ
INSERT INTO Services (Service_ID, Name, Description, Price) VALUES
('S001', N'Giường đôi', N'Giường đôi tiêu chuẩn', 0),
('S002', N'Wifi miễn phí', N'Wifi tốc độ cao miễn phí', 0),
('S003', N'Máy lạnh', N'Điều hòa nhiệt độ', 0),
('S004', N'TV', N'Tivi màn hình phẳng', 0),
('S005', N'Phòng tắm riêng', N'Phòng tắm riêng có nước nóng', 0),

('S006', N'Máy pha cà phê', N'Máy pha cà phê trong phòng', 50000),
('S007', N'Mini bar', N'Tủ đồ uống trong phòng', 200000),
('S008', N'Đồ vệ sinh cá nhân', N'Bộ đồ vệ sinh miễn phí', 0),
('S009', N'Gương trang điểm', N'Gương trang điểm có đèn', 0),
('S010', N'Điện thoại nội bộ', N'Liên lạc nội bộ khách sạn', 0),

('S011', N'Bồn tắm / Jacuzzi', N'Bồn tắm cao cấp / Jacuzzi', 300000),
('S012', N'Phòng khách riêng', N'Phòng khách riêng trong suite', 500000),
('S013', N'Spa trong phòng', N'Dịch vụ spa tại phòng', 400000),
('S014', N'Room service 24/7', N'Phục vụ phòng 24/7', 100000),
('S015', N'Rượu / minibar cao cấp', N'Minibar cao cấp với rượu', 300000);

-- 4. Thêm dữ liệu 10 Phòng
INSERT INTO Rooms (Room_ID, Room_Number, Room_type, Capacity, Price_Per_Night, Status) VALUES
('R01', '101', N'Standard', 2, 500000.00, N'Có sẵn'),
('R02', '102', N'Standard', 2, 500000.00, N'Có sẵn'),
('R03', '103', N'Standard', 2, 500000.00, N'Bảo trì'),
('R04', '201', N'Standard', 2, 800000.00, N'Đã nhận'),
('R05', '202', N'Standard', 3, 900000.00, N'Có sẵn'),
('R06', '203', N'Standard', 3, 900000.00, N'Có sẵn'),
('R07', '301', N'Deluxe', 2, 1200000.00, N'Đã đặt'),
('R08', '302', N'Deluxe', 4, 1500000.00, N'Có sẵn'),
('R09', '401', N'VIP', 2, 2500000.00, N'Bảo trì'),
('R10', '402', N'VIP', 4, 3000000.00, N'Đã đặt');

-- 5. Liên kết Dịch vụ vào Phòng
INSERT INTO Rooms_Services (Room_ID, Service_ID) VALUES
('R01', 'S01'), ('R02', 'S01'), 
('R04', 'S01'), ('R04', 'S02'), 
('R07', 'S01'), ('R07', 'S02'), ('R07', 'S03'), 
('R10', 'S01'), ('R10', 'S02'), ('R10', 'S03'), ('R10', 'S04'); 

-- 6. Thêm Đặt phòng 
INSERT INTO Bookings (Booking_ID, User_ID, Room_ID, Employee_ID, Booking_Date, Room_deposit, Check_In, Check_Out, Status) VALUES
('B01', 'U01', 'R04', 'E02', '2023-11-01 10:00:00', 240000.00, '2023-11-15 14:00:00', '2023-11-16 12:00:00', N'Đã xác nhận'),
('B02', 'U02', 'R07', 'E02', '2023-10-20 09:30:00', 360000.00, '2023-10-25 14:00:00', '2023-10-26 12:00:00', N'Đã trả phòng'),
('B03', 'U03', 'R10', NULL,  '2023-11-05 20:00:00', 900000.00, '2023-11-20 14:00:00', '2023-11-21 12:00:00', N'Đã hủy');

-- 7. Thêm Đánh giá 
INSERT INTO Reviews (Review_ID, User_ID, Booking_ID, Rating, Comment, Created_At) VALUES
('REV01', 'U02', 'B02', 5, N'Khách sạn sạch sẽ, nhân viên E02 phục vụ rất nhiệt tình. Sẽ quay lại!', '2023-10-26 15:00:00');

-- 8. Thêm Thanh toán 
INSERT INTO Payment (Payment_ID, Booking_ID, Amount, Payment_Date, Status) VALUES
('P01', 'B01', 560000.00, NULL, N'Đang chờ xử lý'),
('P02', 'B02', 840000.00, '2023-10-26 12:15:00', N'Thành công'),
('P03', 'B03', 2100000.00, '2023-11-06 08:00:00', N'Thất bại');

-- 9. Thêm Hóa đơn 
INSERT INTO Invoices (Invoice_ID, User_ID, Booking_ID, Total_Amount, Issued_Date) VALUES
('INV01', 'U02', 'B02', 1200000.00, '2023-10-26 12:20:00');

-- 10. Thêm Thông báo
INSERT INTO Notifications (Notification_ID, User_ID, Message, Sent_Date, Is_Read) VALUES
('N01', 'U01', N'Đặt phòng B01 của bạn đã được xác nhận thành công. Vui lòng check-in đúng giờ.', '2023-11-01 10:05:00', 1),
('N02', 'U02', N'Cảm ơn bạn đã lưu trú. Vui lòng để lại đánh giá cho khách sạn.', '2023-10-26 12:30:00', 1),
('N03', 'U03', N'Yêu cầu hủy đơn B03 của bạn đã được hệ thống ghi nhận.', '2023-11-06 08:05:00', 0);
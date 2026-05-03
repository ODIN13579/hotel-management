USE hotel_management;
GO

-- 1. Thêm dữ liệu bảng Users
INSERT INTO Users (User_ID, Name, Email, Phone, Password) VALUES
('U01', N'Nguyễn Văn A', 'nguyenvana@gmail.com', '0901234561', 'hashed_pass_1'),
('U02', N'Trần Thị B', 'tranthib@gmail.com', '0901234562', 'hashed_pass_2'),
('U03', N'Lê Văn C', 'levanc@gmail.com', '0901234563', 'hashed_pass_3'),
('U04', N'Phạm Thị D', 'phamthid@gmail.com', '0901234564', 'hashed_pass_4'),
('U05', N'Hoàng Văn E', 'hoangvane@gmail.com', '0901234565', 'hashed_pass_5');

-- 2. Thêm dữ liệu bảng Employees (Có đủ Lễ tân, Quản lý và 3 trạng thái)
INSERT INTO Employees (Employee_ID, Name, Email, Phone, Password, Role, Status) VALUES
('E01', N'Đinh Lễ Tân', 'letan1@hotel.com', '0801111111', 'hash1', N'Lễ tân', N'Đang làm việc'),
('E02', N'Ngô Quản Lý', 'quanly1@hotel.com', '0802222222', 'hash2', N'Quản lý', N'Nghỉ phép'),
('E03', N'Lý Lễ Tân', 'letan2@hotel.com', '0803333333', 'hash3', N'Lễ tân', N'Nghỉ không phép');

-- 3. Thêm dữ liệu bảng Services (10 dịch vụ)
INSERT INTO Services (Service_ID, Name, Description, Price) VALUES
('S01', N'Buffet Sáng', N'Vé ăn sáng buffet tại nhà hàng', 150000),
('S02', N'Giặt là', N'Dịch vụ giặt sấy quần áo trong ngày', 50000),
('S03', N'Spa & Massage', N'Dịch vụ massage thư giãn toàn thân', 500000),
('S04', N'Đưa đón sân bay', N'Xe ô tô 4 chỗ đưa đón sân bay', 300000),
('S05', N'Thuê xe máy', N'Thuê xe tay ga đi lại trong thành phố', 150000),
('S06', N'Mini Bar', N'Sử dụng các đồ uống có cồn trong tủ lạnh', 200000),
('S07', N'Giường phụ (Extra bed)', N'Thêm 1 giường đơn vào phòng', 300000),
('S08', N'Phòng Gym', N'Thẻ sử dụng phòng Gym 1 ngày', 100000),
('S09', N'Bể bơi vô cực', N'Vé vào cổng bể bơi tầng thượng', 120000),
('S10', N'Trang trí phòng', N'Trang trí hoa hồng và nến cho cặp đôi', 400000);

-- 4. Thêm dữ liệu bảng Rooms (10 phòng R01 - R10, đủ 3 loại và 4 trạng thái)
INSERT INTO Rooms (Room_ID, Room_Number, Room_type, Capacity, Price_Per_Night, Status) VALUES
('R01', '101', 'standard', 2, 500000, N'Có sẵn'),
('R02', '102', 'standard', 2, 500000, N'Có sẵn'),
('R03', '103', 'standard', 2, 500000, N'Bảo trì'),
('R04', '201', 'deluxe', 2, 800000, N'Có sẵn'),
('R05', '202', 'deluxe', 3, 900000, N'Đã đặt'),
('R06', '203', 'deluxe', 2, 800000, N'Đã nhận phòng'),
('R07', '301', 'vip', 2, 1500000, N'Đã nhận phòng'),
('R08', '302', 'vip', 4, 2000000, N'Có sẵn'),
('R09', '303', 'vip', 2, 1500000, N'Đã đặt'),
('R10', '401', 'vip', 4, 2000000, N'Bảo trì');

-- 5. Thêm dữ liệu bảng Rooms_Services (Mỗi phòng 1 dịch vụ)
INSERT INTO Rooms_Services (Room_ID, Service_ID) VALUES
('R01', 'S01'), ('R02', 'S02'), ('R03', 'S03'), ('R04', 'S04'), ('R05', 'S05'),
('R06', 'S06'), ('R07', 'S07'), ('R08', 'S08'), ('R09', 'S09'), ('R10', 'S10');

-- 6. Thêm dữ liệu bảng Bookings (Ngày sớm nhất là 29/04/2026, đủ các trạng thái)
INSERT INTO Bookings (Booking_ID, User_ID, Room_ID, Employee_ID, Booking_Date, Room_deposit, Check_In, Check_Out, Status) VALUES
('B01', 'U01', 'R01', 'E01', '2026-04-29 08:00:00', 150000, '2026-04-29 14:00:00', '2026-04-30 12:00:00', N'Đã trả phòng'), 
('B02', 'U02', 'R02', 'E01', '2026-04-29 09:00:00', 150000, '2026-04-29 14:00:00', '2026-04-30 12:00:00', N'Đã trả phòng'),
('B03', 'U03', 'R03', 'E01', '2026-04-29 10:00:00', 150000, '2026-04-30 14:00:00', '2026-05-02 12:00:00', N'Đã hủy'), -- Phòng trống, mang đi bảo trì
('B04', 'U04', 'R04', 'E01', '2026-04-29 11:00:00', 240000, '2026-04-29 14:00:00', '2026-04-30 12:00:00', N'Đã trả phòng'),
('B05', 'U05', 'R05', 'E01', '2026-04-29 15:00:00', 270000, '2026-05-02 14:00:00', '2026-05-04 12:00:00', N'Đã xác nhận'), -- Phòng "đã đặt"
('B06', 'U01', 'R06', 'E01', '2026-04-29 16:00:00', 240000, '2026-04-29 14:00:00', '2026-05-02 12:00:00', N'Đã nhận phòng'), -- Phòng "đã nhận"
('B07', 'U02', 'R07', 'E01', '2026-04-30 08:00:00', 450000, '2026-04-30 14:00:00', '2026-05-01 12:00:00', N'Đã nhận phòng'), -- Phòng "đã nhận"
('B08', 'U03', 'R08', NULL,  '2026-04-29 09:00:00', 600000, '2026-05-01 14:00:00', '2026-05-02 12:00:00', N'Đã hủy'), 
('B09', 'U04', 'R09', 'E01', '2026-04-30 10:00:00', 450000, '2026-05-05 14:00:00', '2026-05-07 12:00:00', N'Đã xác nhận'), -- Phòng "đã đặt"
('B10', 'U05', 'R10', 'E01', '2026-04-29 20:00:00', 600000, '2026-04-29 14:00:00', '2026-04-30 12:00:00', N'Đã trả phòng'); -- Trả xong mang đi bảo trì

-- 7. Thêm dữ liệu bảng Reviews (10 đánh giá cho 10 booking, đảm bảo mỗi phòng đều có đánh giá)
INSERT INTO Reviews (Review_ID, User_ID, Booking_ID, Rating, Comment, Created_At) VALUES
('RV01', 'U01', 'B01', 4, N'Phòng sạch sẽ, nhân viên nhiệt tình.', '2026-04-30 12:30:00'),
('RV02', 'U02', 'B02', 5, N'Rất hài lòng với chất lượng dịch vụ.', '2026-04-30 12:45:00'),
('RV03', 'U03', 'B03', 3, N'Tôi phải hủy phòng vì bận việc đột xuất.', '2026-04-29 15:00:00'),
('RV04', 'U04', 'B04', 5, N'View phòng cực kỳ đẹp!', '2026-04-30 13:00:00'),
('RV05', 'U05', 'B05', 4, N'Đã cọc tiền, rất mong chờ chuyến đi sắp tới.', '2026-04-29 16:00:00'),
('RV06', 'U01', 'B06', 4, N'Đang lưu trú, giường rất êm.', '2026-04-29 20:00:00'),
('RV07', 'U02', 'B07', 5, N'Phòng VIP cực kỳ đáng tiền.', '2026-04-30 15:00:00'),
('RV08', 'U03', 'B08', 4, N'Hỗ trợ hủy phòng khá nhanh chóng.', '2026-04-29 10:00:00'),
('RV09', 'U04', 'B09', 5, N'Hỗ trợ đặt phòng rất nhiệt tình.', '2026-04-30 10:30:00'),
('RV10', 'U05', 'B10', 1, N'Phòng bị hỏng điều hòa, trải nghiệm tệ.', '2026-04-30 12:15:00');

-- 8. Thêm dữ liệu bảng Payment (Đủ 3 trạng thái chờ xử lý, thành công, thất bại)
INSERT INTO Payment (Payment_ID, Booking_ID, Amount, Payment_Date, Status) VALUES
('P01', 'B01', 350000, '2026-04-30 12:00:00', N'Thành công'),
('P02', 'B02', 350000, '2026-04-30 12:00:00', N'Thành công'),
('P03', 'B03', 0,      '2026-04-29 10:30:00', N'Thất bại'),
('P04', 'B04', 560000, '2026-04-30 12:00:00', N'Thành công'),
('P05', 'B05', 630000, '2026-04-29 15:00:00', N'Đang chờ xử lý'),
('P06', 'B06', 560000, '2026-04-29 16:00:00', N'Đang chờ xử lý'),
('P07', 'B07', 1050000,'2026-04-30 08:00:00', N'Đang chờ xử lý'),
('P08', 'B08', 0,      '2026-04-29 09:30:00', N'Thất bại'),
('P09', 'B09', 1050000,'2026-04-30 10:00:00', N'Đang chờ xử lý'),
('P10', 'B10', 1400000,'2026-04-30 12:00:00', N'Thành công');

-- 9. Thêm dữ liệu bảng Invoices (Dành cho các đơn đã check-out)
INSERT INTO Invoices (Invoice_ID, User_ID, Booking_ID, Total_Amount, Issued_Date) VALUES
('INV01', 'U01', 'B01', 500000, '2026-04-30 12:00:00'),
('INV02', 'U02', 'B02', 500000, '2026-04-30 12:00:00'),
('INV04', 'U04', 'B04', 800000, '2026-04-30 12:00:00'),
('INV10', 'U05', 'B10', 2000000,'2026-04-30 12:00:00');

-- 10. Thêm dữ liệu bảng Notifications
INSERT INTO Notifications (Notification_ID, User_ID, Message, Sent_Date, Is_Read) VALUES
('N01', 'U01', N'Cảm ơn bạn đã sử dụng dịch vụ!', '2026-04-30 12:10:00', 1),
('N02', 'U03', N'Đơn đặt phòng B03 của bạn đã bị hủy thành công.', '2026-04-29 10:35:00', 0),
('N03', 'U05', N'Nhắc nhở: Sắp đến ngày check-in đơn B05.', '2026-04-30 18:00:00', 0);
GO
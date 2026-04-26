
INSERT INTO Users VALUES
('U001', N'Nguyễn Văn A', 'u1@gmail.com', '0900000001', 'hash1'),
('U002', N'Trần Thị B', 'u2@gmail.com', '0900000002', 'hash2'),
('U003', N'Lê Văn C', 'u3@gmail.com', '0900000003', 'hash3'),
('U004', N'Phạm Thị D', 'u4@gmail.com', '0900000004', 'hash4'),
('U005', N'Hoàng Văn E', 'u5@gmail.com', '0900000005', 'hash5'),
('U006', N'Đỗ Thị F', 'u6@gmail.com', '0900000006', 'hash6'),
('U007', N'Võ Văn G', 'u7@gmail.com', '0900000007', 'hash7'),
('U008', N'Bùi Thị H', 'u8@gmail.com', '0900000008', 'hash8'),
('U009', N'Ngô Văn I', 'u9@gmail.com', '0900000009', 'hash9'),
('U010', N'Dương Thị K', 'u10@gmail.com', '0900000010', 'hash10');

INSERT INTO Employees VALUES
('E001', N'Admin', 'e1@gmail.com', '0910000001', 'hash', 'Admin', 'available'),
('E002', N'Lễ tân 1', 'e2@gmail.com', '0910000002', 'hash', 'Receptionist', 'available'),
('E003', N'Lễ tân 2', 'e3@gmail.com', '0910000003', 'hash', 'Receptionist', 'processing'),
('E004', N'Quản lý', 'e4@gmail.com', '0910000004', 'hash', 'Manager', 'available'),
('E005', N'Nhân viên', 'e5@gmail.com', '0910000005', 'hash', 'Staff', 'available'),
('E006', N'Nhân viên', 'e6@gmail.com', '0910000006', 'hash', 'Staff', 'processing'),
('E007', N'Nhân viên', 'e7@gmail.com', '0910000007', 'hash', 'Staff', 'available'),
('E008', N'Nhân viên', 'e8@gmail.com', '0910000008', 'hash', 'Staff', 'available'),
('E009', N'Nhân viên', 'e9@gmail.com', '0910000009', 'hash', 'Staff', 'processing'),
('E010', N'Nhân viên', 'e10@gmail.com', '0910000010', 'hash', 'Staff', 'available');

INSERT INTO Services VALUES
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

INSERT INTO Rooms VALUES
('R001','101','Standard',2,500000,'available'),
('R002','102','Standard',2,500000,'booked'),
('R003','103','VIP',2,1500000,'available'),
('R004','104','VIP',4,2000000,'available'),
('R005','105','Deluxe',3,1000000,'booked'),
('R006','106','Standard',2,500000,'available'),
('R007','107','Deluxe',3,1200000,'available'),
('R008','108','VIP',2,1800000,'booked'),
('R009','109','Standard',2,500000,'available'),
('R010','110','Deluxe',4,1300000,'available');

INSERT INTO Rooms_Services VALUES
('R001','S001'),
('R002','S002'),
('R003','S003'),
('R004','S004'),
('R005','S005'),
('R006','S006'),
('R007','S007'),
('R008','S008'),
('R009','S009'),
('R010','S010');

INSERT INTO Bookings VALUES
('B001','U001','R002','E002','2026-04-01',100000,'2026-04-05','2026-04-06','confirmed'),
('B002','U002','R005','E003','2026-04-01',100000,'2026-04-06','2026-04-07','confirmed'),
('B003','U003','R008','E002','2026-04-02',200000,'2026-04-05','2026-04-07','confirmed'),

('B004','U004','R001','E003','2026-04-02',100000,'2026-04-05','2026-04-06','checkedout'),
('B005','U005','R003','E002','2026-04-03',200000,'2026-04-06','2026-04-08','checkedout'),
('B006','U006','R004','E003','2026-04-03',300000,'2026-04-06','2026-04-09','checkedout'),

('B007','U007','R006',NULL,'2026-04-04',100000,'2026-04-08','2026-04-09','cancelled'),
('B008','U008','R007',NULL,'2026-04-04',100000,'2026-04-09','2026-04-10','cancelled'),
('B009','U009','R009',NULL,'2026-04-05',100000,'2026-04-10','2026-04-11','cancelled'),

('B010','U010','R010','E002','2026-04-05',200000,'2026-04-11','2026-04-13','confirmed');

INSERT INTO Reviews VALUES
('RV001','U001','B001',5,N'Tốt','2026-04-06'),
('RV002','U002','B002',4,N'Ổn','2026-04-07'),
('RV003','U003','B003',5,N'Rất tốt','2026-04-07'),
('RV004','U004','B004',3,N'Bình thường','2026-04-06'),
('RV005','U005','B005',4,N'Khá tốt','2026-04-08'),
('RV006','U006','B006',5,N'Tuyệt vời','2026-04-09'),
('RV007','U007','B007',2,N'Không hài lòng','2026-04-09'),
('RV008','U008','B008',3,N'Ổn','2026-04-10'),
('RV009','U009','B009',1,N'Tệ','2026-04-11'),
('RV010','U010','B010',5,N'Xuất sắc','2026-04-13');

INSERT INTO Payment VALUES
('P001','B001',500000,'2026-04-06','successful'),
('P002','B002',500000,'2026-04-07','pending'),
('P003','B003',1500000,'2026-04-07','successful'),

('P004','B004',500000,'2026-04-06','successful'),
('P005','B005',1500000,'2026-04-08','successful'),
('P006','B006',2000000,'2026-04-09','Transfer','successful'),

('P007','B007',500000,'2026-04-09','failed'),
('P008','B008',500000,'2026-04-10', 'failed'),
('P009','B009',500000,'2026-04-11','failed'),

('P010','B010',1300000,'2026-04-13','pending');

INSERT INTO Invoices VALUES
('I001','U001','B001',500000,'2026-04-06'),
('I002','U002','B002',500000,'2026-04-07'),
('I003','U003','B003',1500000,'2026-04-07'),
('I004','U004','B004',500000,'2026-04-06'),
('I005','U005','B005',1500000,'2026-04-08'),
('I006','U006','B006',2000000,'2026-04-09'),
('I007','U007','B007',500000,'2026-04-09'),
('I008','U008','B008',500000,'2026-04-10'),
('I009','U009','B009',500000,'2026-04-11'),
('I010','U010','B010',1300000,'2026-04-13');

INSERT INTO Notifications VALUES
('N001','U001',N'Đặt phòng thành công','2026-04-01',1),
('N002','U002',N'Chờ thanh toán','2026-04-01',0),
('N003','U003',N'Xác nhận booking','2026-04-02',1),
('N004','U004',N'Check-out thành công','2026-04-06',1),
('N005','U005',N'Thanh toán thành công','2026-04-08',1),
('N006','U006',N'Hoàn tất','2026-04-09',1),
('N007','U007',N'Đã hủy booking','2026-04-09',1),
('N008','U008',N'Booking bị hủy','2026-04-10',1),
('N009','U009',N'Thanh toán thất bại','2026-04-11',1),
('N010','U010',N'Nhắc thanh toán','2026-04-12',0);
USE hotel_management;

/* Clear sample data in safe order */
DELETE FROM Notifications;
DELETE FROM Reviews;
DELETE FROM Invoices;
DELETE FROM Payment;
DELETE FROM Bookings;
DELETE FROM Rooms_Services;
DELETE FROM Services;
DELETE FROM Rooms;
DELETE FROM Employees;
DELETE FROM Users;

/* Users */
INSERT INTO Users (User_ID, Name, Email, Phone, Password) VALUES
('U001', 'Nguyen Van A', 'a@example.com', '0900000001', '123456'),
('U002', 'Tran Thi B', 'b@example.com', '0900000002', '123456'),
('U003', 'Le Van C', 'c@example.com', '0900000003', '123456');

/* Employees */
INSERT INTO Employees (Employee_ID, Name, Email, Phone, Password, Role, Status) VALUES
('E001', 'Quyen', 'quyen@hotel.com', '0911000001', '123456', 'receptionist', 'active'),
('E002', 'Tuan', 'tuan@hotel.com', '0911000002', '123456', 'manager', 'active'),
('E003', 'Lam Tuan', 'lamtuan@hotel.com', '0911000003', '123456', 'receptionist', 'on_leave');

/* Rooms */
INSERT INTO Rooms (Room_ID, Room_Number, RoomType, Capacity, Price_Per_Night, Status) VALUES
('R001', '101', 'Single', 1, 500000, 'available'),
('R002', '102', 'Double', 2, 800000, 'available'),
('R003', '201', 'Deluxe', 2, 1200000, 'available'),
('R004', '202', 'Suite', 4, 2000000, 'maintenance');

/* Services */
INSERT INTO Services (Service_ID, Name, Description, Price) VALUES
('S001', 'Breakfast', 'Breakfast buffet', 100000),
('S002', 'Laundry', 'Laundry service', 80000),
('S003', 'Airport Pickup', 'Airport transfer', 300000);

INSERT INTO Rooms_Services (Room_ID, Service_ID) VALUES
('R001', 'S001'),
('R002', 'S001'),
('R002', 'S002'),
('R003', 'S001'),
('R003', 'S002'),
('R003', 'S003');

/* Bookings */
INSERT INTO Bookings (Booking_ID, User_ID, Room_ID, Employee_ID, Booking_Date, Check_In, Check_Out, Status) VALUES
('B001', 'U001', 'R001', NULL, '2025-01-02 10:00:00', '2025-01-05 14:00:00', '2025-01-07 12:00:00', 'pending'),
('B002', 'U002', 'R002', 'E001', '2025-01-03 11:00:00', '2025-01-10 14:00:00', '2025-01-13 12:00:00', 'completed'),
('B003', 'U003', 'R003', 'E002', '2025-01-08 09:30:00', '2025-01-15 14:00:00', '2025-01-18 12:00:00', 'completed'),
('B004', 'U001', 'R002', NULL, '2025-01-17 15:45:00', '2025-01-20 14:00:00', '2025-01-22 12:00:00', 'pending'),
('B005', 'U002', 'R001', 'E001', '2025-02-01 10:00:00', '2025-02-05 14:00:00', '2025-02-08 12:00:00', 'confirmed'),
('B006', 'U003', 'R003', 'E002', '2025-02-10 09:00:00', '2025-02-12 14:00:00', '2025-02-16 12:00:00', 'checked_in'),
('B007', 'U001', 'R001', NULL, '2025-02-14 16:00:00', '2025-02-20 14:00:00', '2025-02-23 12:00:00', 'cancelled'),
('B008', 'U002', 'R002', 'E002', '2025-02-20 08:30:00', '2025-02-25 14:00:00', '2025-02-28 12:00:00', 'completed');

/* Payments */
INSERT INTO Payment (Payment_ID, Booking_ID, Amount, Payment_Date, Payment_Method, Status) VALUES
('P001', 'B002', 2400000, '2025-01-10 18:30:00', 'cash', 'paid'),
('P002', 'B003', 3600000, '2025-01-15 19:00:00', 'card', 'paid'),
('P003', 'B005', 1500000, '2025-02-05 20:15:00', 'bank_transfer', 'paid'),
('P004', 'B006', 4800000, '2025-02-12 21:10:00', 'card', 'paid'),
('P005', 'B008', 2400000, '2025-02-25 17:40:00', 'cash', 'paid');

/* Invoices */
INSERT INTO Invoices (Invoice_ID, User_ID, Booking_ID, Total_Amount, Issued_Date) VALUES
('I001', 'U002', 'B002', 2400000, '2025-01-10 18:35:00'),
('I002', 'U003', 'B003', 3600000, '2025-01-15 19:05:00'),
('I003', 'U002', 'B005', 1500000, '2025-02-05 20:20:00'),
('I004', 'U003', 'B006', 4800000, '2025-02-12 21:15:00'),
('I005', 'U002', 'B008', 2400000, '2025-02-25 17:45:00');

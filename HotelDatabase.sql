use hotell
GO DROP TABLE IF EXISTS Payment DROP TABLE IF EXISTS Invoices DROP TABLE IF EXISTS CancellationRefund DROP TABLE IF EXISTS Reviews DROP TABLE IF EXISTS Notifications DROP TABLE IF EXISTS Bookings DROP TABLE IF EXISTS Rooms DROP TABLE IF EXISTS Services DROP TABLE IF EXISTS Employees DROP TABLE IF EXISTS Users
GO
go create table Users(
        UserID varchar(50) PRIMARY KEY,
        -- kí tự + sô
        Email varchar(50),
        Phone varchar(50)
    )
go
INSERT INTO Users
VALUES ('U001', 'user1@gmail.com', '0901111111'),
    ('U002', 'user2@gmail.com', '0902222222'),
    ('U003', 'user3@gmail.com', '0903333333')
go create table Employees(
        EmployeeID varchar(50) PRIMARY KEY,
        Name nvarchar(50),
        Email varchar(50),
        Phone varchar(50),
        Role varchar(50),
        --ENUM VAI TRÒ
        Status varchar(50)
    )
go
INSERT INTO Employees
VALUES (
        'E001',
        N 'Nguyễn Văn A',
        'a@gmail.com',
        '0911111111',
        'Manager',
        'Active'
    ),
    (
        'E002',
        N'Trần Thị B',
        'b@gmail.com',
        '0922222222',
        'Receptionist',
        'Active'
    ),
    (
        'E003',
        N'Lê Văn C',
        'c@gmail.com',
        '0933333333',
        'Cleaner',
        'Inactive'
    )
go create table Services(
        ServiceID varchar(50) PRIMARY KEY,
        Name nvarchar(50),
        Description nvarchar(50),
        Price float
    )
go
INSERT INTO Services
VALUES ('S01', 'Spa', 'Massage thu gian', 200.00),
    ('S02', 'Breakfast', 'Buffet sang', 100.00),
    ('S03', 'Airport Pickup', 'Xe dua don', 300.00)
go create table Rooms(
        RoomID varchar(50) PRIMARY KEY,
        RoomNumber varchar(50),
        ServiceID varchar(50),
        Capacity integer,
        PricePerNight decimal,
        Status varchar(50),
        FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID),
    )
go
INSERT INTO Rooms
VALUES ('R01', '101', 'S01', 2, 500.00, 'Available'),
    ('R02', '102', 'S02', 3, 800.00, 'Occupied'),
    go CREATE TABLE Bookings(
        BookingID varchar(50) PRIMARY KEY,
        UserID varchar(50),
        RoomID varchar(50),
        EmployeeID varchar(50),
        Date datetime,
        CheckIn datetime,
        CheckOut datetime,
        Status varchar(50),
        FOREIGN KEY (UserID) REFERENCES Users(UserID),
        FOREIGN KEY (RoomID) REFERENCES Rooms(RoomID),
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
    )
go
INSERT INTO Bookings
VALUES (
        'B001',
        'U001',
        'R01',
        NOW(),
        '2026-04-01',
        '2026-04-03',
        'Confirmed'
    ),
    GO CREATE TABLE PAYMENT(
        PaymentID varchar(50) PRIMARY KEY,
        BookingID varchar (50),
        Amount VARCHAR(50),
        PaymentDate datetime,
        PaymentMethod varchar(50),
        FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
    ),
    go
INSERT INTO Payment
VALUES ('P001', 'B001', 1000.00, GETDATE(), 'Cash'),
    ('P002', 'B002', 2000.00, GETDATE(), 'Card'),
    go create table Notifications(
        NotificationID varchar(50) primary key,
        UserID varchar(50),
        Message nvarchar(50),
        Date datetime,
        FOREIGN KEY (UserID) REFERENCES Users(UserID)
    )
go
INSERT INTO Notifications
VALUES (
        'N001',
        'U001',
        N'Đặt phòng thành công',
        GETDATE()
    ),
    (
        'N002',
        'U002',
        N'Vui lòng thanh toán',
        GETDATE()
    ),
    go create table Invoices(
        InvoiceID varchar(50) PRIMARY KEY,
        UserID varchar(50),
        BookingID varchar(50),
        Amount float,
        Date datetime,
        FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID),
        FOREIGN KEY (UserID) REFERENCES Users(UserID)
    )
go
INSERT INTO Invoices
VALUES ('I001', 'U001', 'B001', 1000.00, GETDATE()),
    ('I002', 'U002', 'B002', 2000.00, GETDATE()),
    go create table CancellationRefund(
        CancellationRefundID varchar(50) PRIMARY KEY,
        BookingID varchar(50),
        Refund_Amount float,
        FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
    )
go
INSERT INTO CancellationRefund
VALUES ('CR01', 'B002', 500.00),
    go create table Reviews(
        RiviewID varchar(50) PRIMARY KEY,
        UserID varchar(50),
        ServiceID varchar(50),
        Rating integer,
        Comment nvarchar(50),
        FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID),
        FOREIGN KEY (UserID) REFERENCES Users(UserID)
    )
go
INSERT INTO Reviews
VALUES ('RV01', 'U001', 'S01', 5, N'Rất tốt'),
    ('RV02', 'U002', 'S02', 4, N'Ổn áp'),
    ('RV03', 'U003', 'S03', 3, N'Bình thường');
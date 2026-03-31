-- tạo database
DROP DATABASE IF EXISTS hotel_management;
CREATE DATABASE hotel_management;
USE hotel_management;
-- xoa bang neu da ton tai
DROP TABLE IF EXISTS Notifications;
DROP TABLE IF EXISTS Invoices;
DROP TABLE IF EXISTS CancellationRefund;
DROP TABLE IF EXISTS Payment;
DROP TABLE IF EXISTS Reviews;
DROP TABLE IF EXISTS Bookings;
DROP TABLE IF EXISTS Rooms_Services;
DROP TABLE IF EXISTS Rooms;
DROP TABLE IF EXISTS Employees;
DROP TABLE IF EXISTS Services;
DROP TABLE IF EXISTS Users;
-- tao cac bang o day
CREATE TABLE Users (
    User_ID VARCHAR(50) NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    Phone VARCHAR(20) UNIQUE,
    Password VARCHAR(255) NOT NULL,
    PRIMARY KEY (User_ID)
);

CREATE TABLE Services (
    Service_ID VARCHAR(50) NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(1000),
    Price DECIMAL(18, 2) NOT NULL,
    PRIMARY KEY (Service_ID)
);

CREATE TABLE Employees (
    Employee_ID VARCHAR(50) NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    Phone VARCHAR(20) UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Role NVARCHAR(100),
    Status NVARCHAR(50), -- Đang làm việc, Nghỉ phép, Đã nghỉ việc
    PRIMARY KEY (Employee_ID)
);

CREATE TABLE Rooms (
    Room_ID VARCHAR(50) NOT NULL,
    Room_Number VARCHAR(20) NOT NULL,
    Capacity INT DEFAULT 1,
    Price_Per_Night DECIMAL(18, 2) NOT NULL,
    Status NVARCHAR(50), -- Trống, Đã đặt, Đang ở, Bảo trì
    PRIMARY KEY (Room_ID)
);


-- bảng trung gian rooms_services (n-n)
CREATE TABLE Rooms_Services (
    Room_ID VARCHAR(50) NOT NULL,
    Service_ID VARCHAR(50) NOT NULL,
    PRIMARY KEY (Room_ID, Service_ID),
    FOREIGN KEY (Room_ID) REFERENCES Rooms(Room_ID) ON DELETE CASCADE,
    FOREIGN KEY (Service_ID) REFERENCES Services(Service_ID) ON DELETE CASCADE
);

CREATE TABLE Bookings (
    Booking_ID VARCHAR(50) NOT NULL,
    User_ID VARCHAR(50),
    Room_ID VARCHAR(50),
    Employee_ID VARCHAR(50),
    Booking_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Check_In DATETIME,
    Check_Out DATETIME,
    Status NVARCHAR(50), -- Chờ xác nhận, Đã nhận phòng, Đã trả phòng, Đã hủy
    PRIMARY KEY (Booking_ID),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Room_ID) REFERENCES Rooms(Room_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID)
);

CREATE TABLE Reviews (
    Review_ID VARCHAR(50) NOT NULL,
    User_ID VARCHAR(50),
    Booking_ID VARCHAR(50),
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(1000),
    PRIMARY KEY (Review_ID),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE Payment (
    Payment_ID VARCHAR(50) NOT NULL,
    Booking_ID VARCHAR(50),
    Amount DECIMAL(18, 2) NOT NULL,
    Payment_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Payment_Method NVARCHAR(100), -- Tiền mặt, Thẻ, Chuyển khoảng
    PRIMARY KEY (Payment_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE CancellationRefund (
    CancellationRefund_ID VARCHAR(50) NOT NULL,
    Booking_ID VARCHAR(50) UNIQUE,
    Cancellation_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    Refund_Amount DECIMAL(18, 2),
    PRIMARY KEY (CancellationRefund_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE Invoices (
    Invoice_ID VARCHAR(50) NOT NULL,
    User_ID VARCHAR(50),
    Booking_ID VARCHAR(50) UNIQUE,
    Total_Amount DECIMAL(18, 2) NOT NULL,
    Issued_Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Invoice_ID),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE Notifications (
    Notification_ID VARCHAR(50) NOT NULL,
    User_ID VARCHAR(50),
    Message NVARCHAR(1000),
    Date DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (Notification_ID),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID)
);
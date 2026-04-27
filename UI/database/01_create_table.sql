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
    Password VARCHAR(255) NOT NULL, -- Sẽ lưu hash
    PRIMARY KEY (User_ID)
);

CREATE TABLE Employees (
    Employee_ID VARCHAR(50) NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Email VARCHAR(255) UNIQUE,
    Phone VARCHAR(20) UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Role NVARCHAR(100),
    Status NVARCHAR(50),
    PRIMARY KEY (Employee_ID)
);

CREATE TABLE Services (
    Service_ID VARCHAR(50) NOT NULL,
    Name NVARCHAR(255) NOT NULL,
    Description NVARCHAR(1000),
    Price DECIMAL(18, 2) NOT NULL,
    PRIMARY KEY (Service_ID)
);

CREATE TABLE Rooms (
    Room_ID VARCHAR(50) NOT NULL,
    Room_Number VARCHAR(20) NOT NULL UNIQUE,
    Room_type NVARCHAR(100),
    Capacity INT,
    Price_Per_Night DECIMAL(18, 2) NOT NULL,
    Status NVARCHAR(50), -- Trống, Đã đặt (cọc), Đã nhận, Bảo trì
    PRIMARY KEY (Room_ID)
);

CREATE TABLE Rooms_Services (
    Room_ID VARCHAR(50) NOT NULL,
    Service_ID VARCHAR(50) NOT NULL,
    PRIMARY KEY (Room_ID, Service_ID),
    FOREIGN KEY (Room_ID) REFERENCES Rooms(Room_ID) ON DELETE CASCADE,
    FOREIGN KEY (Service_ID) REFERENCES Services(Service_ID) ON DELETE CASCADE
);

CREATE TABLE Bookings (
    Booking_ID VARCHAR(50) NOT NULL,
    User_ID VARCHAR(50) NOT NULL,
    Room_ID VARCHAR(50) NOT NULL,
    Employee_ID VARCHAR(50) NULL, -- Có thể NULL nếu khách tự đặt online
    Booking_Date DATETIME DEFAULT GETDATE(),
    Room_deposit DECIMAL(18, 2), -- 30% giá phòng
    Check_In DATETIME NOT NULL,
    Check_Out DATETIME NOT NULL,
    Status NVARCHAR(50), -- Đã xác nhận, Đã trả phòng, Đã hủy
    PRIMARY KEY (Booking_ID),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Room_ID) REFERENCES Rooms(Room_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID)
);

-- Quan hệ 1-1 với Booking
CREATE TABLE Reviews (
    Review_ID VARCHAR(50) NOT NULL,
    User_ID VARCHAR(50) NOT NULL,
    Booking_ID VARCHAR(50) NOT NULL UNIQUE, 
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(1000),
    Created_At DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (Review_ID),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE Payment (
    Payment_ID VARCHAR(50) NOT NULL,
    Booking_ID VARCHAR(50) NOT NULL,
    Amount DECIMAL(18, 2) NOT NULL, -- 70% còn lại sau cọc
    Payment_Date DATETIME DEFAULT GETDATE(),
    -- Payment_Method NVARCHAR(100),
    Status NVARCHAR(50),
    PRIMARY KEY (Payment_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

-- Quan hệ 1-1 với Booking 
CREATE TABLE Invoices (
    Invoice_ID VARCHAR(50) NOT NULL,
    User_ID VARCHAR(50) NOT NULL,
    Booking_ID VARCHAR(50) NOT NULL UNIQUE,
    Total_Amount DECIMAL(18, 2) NOT NULL, -- Tổng (30% cọc + 70% còn lại)
    Issued_Date DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (Invoice_ID),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE Notifications (
    Notification_ID VARCHAR(50) NOT NULL,
    User_ID VARCHAR(50) NOT NULL,
    Message NVARCHAR(1000) NOT NULL,
    Sent_Date DATETIME DEFAULT GETDATE(),
    Is_Read BIT DEFAULT 0,
    PRIMARY KEY (Notification_ID),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID)
);
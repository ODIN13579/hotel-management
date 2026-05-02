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
    User_ID VARCHAR(10) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15) UNIQUE,
    Password VARCHAR(255) NOT NULL
);
GO

CREATE TABLE Employees (
    Employee_ID VARCHAR(10) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(15) UNIQUE,
    Password VARCHAR(255) NOT NULL,
    Role VARCHAR(50),
    Status NVARCHAR(50)
);

CREATE TABLE Services (
    Service_ID VARCHAR(10) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL,
    Description NVARCHAR(255),
    Price DECIMAL(18,2)
);

CREATE TABLE Rooms (
    Room_ID VARCHAR(10) PRIMARY KEY,
    Room_Number VARCHAR(10) UNIQUE NOT NULL,
    Room_type VARCHAR(50),
    Capacity INT,
    Price_Per_Night DECIMAL(18,2),
    Status VARCHAR(50)
);

CREATE TABLE Rooms_Services (
    Room_ID VARCHAR(10),
    Service_ID VARCHAR(10),
    PRIMARY KEY (Room_ID, Service_ID),
    FOREIGN KEY (Room_ID) REFERENCES Rooms(Room_ID),
    FOREIGN KEY (Service_ID) REFERENCES Services(Service_ID)
);

CREATE TABLE Bookings (
    Booking_ID VARCHAR(10) PRIMARY KEY,
    User_ID VARCHAR(10),
    Room_ID VARCHAR(10),
    Employee_ID VARCHAR(10) NULL,
    Booking_Date DATETIME,
    Room_deposit DECIMAL(18,2),
    Check_In DATETIME,
    Check_Out DATETIME,
    Status VARCHAR(50),

    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Room_ID) REFERENCES Rooms(Room_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID)
);

CREATE TABLE Reviews (
    Review_ID VARCHAR(10) PRIMARY KEY,
    User_ID VARCHAR(10),
    Booking_ID VARCHAR(10) UNIQUE, -- đảm bảo 1 booking chỉ 1 review
    Rating INT CHECK (Rating BETWEEN 1 AND 5),
    Comment NVARCHAR(255),
    Created_At DATETIME,

    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE Payment (
    Payment_ID VARCHAR(10) PRIMARY KEY,
    Booking_ID VARCHAR(10),
    Amount DECIMAL(18,2),
    Payment_Date DATETIME,
    Payment_Method VARCHAR(50),
    Status NVARCHAR(50),

    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE Invoices (
    Invoice_ID VARCHAR(10) PRIMARY KEY,
    User_ID VARCHAR(10),
    Booking_ID VARCHAR(10) UNIQUE,
    Total_Amount DECIMAL(18,2),
    Issued_Date DATETIME,

    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE Notifications (
    Notification_ID VARCHAR(10) PRIMARY KEY,
    User_ID VARCHAR(10),
    Message NVARCHAR(255),
    Sent_Date DATETIME,
    Is_Read BIT,

    FOREIGN KEY (User_ID) REFERENCES Users(User_ID)
);
DROP DATABASE IF EXISTS hotel_management;
CREATE DATABASE hotel_management;
USE hotel_management;

CREATE TABLE Users (
    User_ID VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Password VARCHAR(100)
);

CREATE TABLE Rooms (
    Room_ID VARCHAR(50) PRIMARY KEY,
    Room_Number VARCHAR(50),
    Capacity INT,
    Price_Per_Night DECIMAL(10,2),
    Status VARCHAR(50),
    RoomType VARCHAR(50)
);

CREATE TABLE Employees (
    Employee_ID VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(20),
    Password VARCHAR(100),
    Role VARCHAR(50),
    Status VARCHAR(50)
);

CREATE TABLE Bookings (
    Booking_ID VARCHAR(50) PRIMARY KEY,
    User_ID VARCHAR(50),
    Room_ID VARCHAR(50),
    Employee_ID VARCHAR(50),
    Booking_Date DATETIME,
    Check_In DATETIME,
    Check_Out DATETIME,
    Status VARCHAR(50),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Room_ID) REFERENCES Rooms(Room_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID)
);

CREATE TABLE Services (
    Service_ID VARCHAR(50) PRIMARY KEY,
    Name VARCHAR(100),
    Description TEXT,
    Price DECIMAL(10,2)
);

CREATE TABLE Rooms_Services (
    Room_ID VARCHAR(50),
    Service_ID VARCHAR(50),
    PRIMARY KEY (Room_ID, Service_ID),
    FOREIGN KEY (Room_ID) REFERENCES Rooms(Room_ID),
    FOREIGN KEY (Service_ID) REFERENCES Services(Service_ID)
);

CREATE TABLE Payment (
    Payment_ID VARCHAR(50) PRIMARY KEY,
    Booking_ID VARCHAR(50),
    Amount DECIMAL(10,2),
    Payment_Date DATETIME,
    Payment_Method VARCHAR(50),
    Status VARCHAR(50),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);
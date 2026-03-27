drop database if exists hotell;
create database hotell;
CREATE TABLE Users (
    User_ID VARCHAR(255) NOT NULL PRIMARY KEY,
    Name NVARCHAR(255),
    Email VARCHAR(255) UNIQUE,
    Phone VARCHAR(50)
);

CREATE TABLE Services (
    Service_ID VARCHAR(255) NOT NULL PRIMARY KEY,
    Name NVARCHAR(255),
    Description NVARCHAR(1000),
    Price FLOAT
);

CREATE TABLE Employees (
    Employee_ID VARCHAR(255) NOT NULL PRIMARY KEY,
    Name NVARCHAR(255),
    Email VARCHAR(255) UNIQUE,
    Phone VARCHAR(50),
    Role VARCHAR(100),
    Status VARCHAR(50)
);

CREATE TABLE Rooms (
    Room_ID VARCHAR(255) NOT NULL PRIMARY KEY,
    Room_Number VARCHAR(50),
    Service_ID VARCHAR(255),
    Capacity INT,
    Price_Per_Night DECIMAL(18,2),
    Status VARCHAR(50),
    FOREIGN KEY (Service_ID) REFERENCES Services(Service_ID)
);

CREATE TABLE Bookings (
    Booking_ID VARCHAR(255) NOT NULL PRIMARY KEY,
    User_ID VARCHAR(255),
    Room_ID VARCHAR(255),
    Employee_ID VARCHAR(255),
    Date DATETIME,
    Check_In DATETIME,
    Check_Out DATETIME,
    Status VARCHAR(50),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Room_ID) REFERENCES Rooms(Room_ID),
    FOREIGN KEY (Employee_ID) REFERENCES Employees(Employee_ID)
);

CREATE TABLE Reviews (
    Riview_ID VARCHAR(255) NOT NULL PRIMARY KEY,
    User_ID VARCHAR(255),
    Service_ID VARCHAR(255),
    Rating INT,
    Comment NVARCHAR(1000),
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Service_ID) REFERENCES Services(Service_ID)
);

CREATE TABLE Payment (
    Payment_ID VARCHAR(255) NOT NULL PRIMARY KEY,
    Booking_ID VARCHAR(255),
    Amount FLOAT,
    Payment_Date DATETIME,
    Payment_Method VARCHAR(100),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE CancellationRefund (
    CancellationRefund_ID VARCHAR(255) NOT NULL PRIMARY KEY,
    Booking_ID VARCHAR(255) UNIQUE, -- 1-1
    Cancellation_Date DATETIME,
    Refund_Amount FLOAT,
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE Invoices (
    Invoice_ID VARCHAR(255) NOT NULL PRIMARY KEY,
    User_ID VARCHAR(255),
    Booking_ID VARCHAR(255) UNIQUE,-- 1-1
    Amount FLOAT,
    Date DATETIME,
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID),
    FOREIGN KEY (Booking_ID) REFERENCES Bookings(Booking_ID)
);

CREATE TABLE Notifications (
    Notification_ID VARCHAR(255) NOT NULL PRIMARY KEY,
    User_ID VARCHAR(255),
    Message NVARCHAR(1000),
    Date DATETIME,
    FOREIGN KEY (User_ID) REFERENCES Users(User_ID)
);

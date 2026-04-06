USE hotel_management;

-- VIEW
-- chức năng 4:
CREATE VIEW vw_services_list AS
SELECT 
    Service_ID,
    Name,
    Description,
    Price
FROM Services;


-- chức năng 5:
CREATE VIEW vw_invoice_detail AS
SELECT 
    i.Invoice_ID,
    u.Name AS Customer_Name,
    b.Booking_ID,
    r.Room_Number,
    i.Total_Amount,
    i.Issued_Date
FROM Invoices i
JOIN Users u ON i.User_ID = u.User_ID
JOIN Bookings b ON i.Booking_ID = b.Booking_ID
JOIN Rooms r ON b.Room_ID = r.Room_ID;



-- function 
DROP FUNCTION IF EXISTS calculate_total;

DELIMITER //

CREATE FUNCTION calculate_total(p_booking_id VARCHAR(255)) 

RETURNS DECIMAL(18,2)
DETERMINISTIC 
BEGIN
    DECLARE total DECIMAL(18,2); 

    SELECT DATEDIFF(Check_Out, Check_In) * r.Price_Per_Night 
    INTO total
    FROM Bookings b
    JOIN Rooms r ON b.Room_ID = r.Room_ID
    WHERE b.Booking_ID = p_booking_id;

    RETURN IFNULL(total,0);
END //

DELIMITER ;


/*=========================================================
===========================================================*/
-- Xóa trigger cũ
DROP TRIGGER IF EXISTS trg_invoice_total;
DROP TRIGGER IF EXISTS trg_booking_room;
DROP TRIGGER IF EXISTS trg_checkout;

-- Trigger chức năng 5: Tính tiền invoice
DELIMITER //
CREATE TRIGGER trg_invoice_total
BEFORE INSERT ON Invoices
FOR EACH ROW
BEGIN
    SET NEW.Total_Amount = calculate_total(NEW.Booking_ID);
END //
DELIMITER ;

-- Trigger 2: Booking → Room = occupied
DELIMITER //

CREATE TRIGGER trg_booking_room
BEFORE INSERT ON Bookings
FOR EACH ROW
BEGIN
    DECLARE room_status VARCHAR(50);

    -- lấy trạng thái phòng
    SELECT Status INTO room_status
    FROM Rooms
    WHERE Room_ID = NEW.Room_ID;

    -- nếu phòng không available → chặn
    IF room_status <> 'available' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Room is not available!';
    END IF;

    -- nếu ok → set occupied
    IF NEW.Status IN ('booked','confirmed') THEN
        UPDATE Rooms
        SET Status = 'occupied'
        WHERE Room_ID = NEW.Room_ID;
    END IF;
END //

DELIMITER ;

-- Trigger 3: Checkout → Room = available
DELIMITER //
CREATE TRIGGER trg_checkout
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.Status = 'completed' AND OLD.Status <> 'completed' THEN
        UPDATE Rooms
        SET Status = 'available'
        WHERE Room_ID = NEW.Room_ID;
    END IF;
END //
DELIMITER ;

-- reset data
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE Invoices;
TRUNCATE TABLE Payment;
TRUNCATE TABLE CancellationRefund;
TRUNCATE TABLE Bookings;
SET FOREIGN_KEY_CHECKS = 1;

/*===========
-- TEST TRIGGER BOOKING
===========*/
INSERT INTO Bookings VALUES
('B100','U001','R003','E001',NOW(),NOW(),DATE_ADD(NOW(), INTERVAL 2 DAY),'confirmed');

-- kiểm tra phòng
SELECT * FROM Rooms WHERE Room_ID = 'R003';

-- TEST TRIGGER INVOICE
INSERT INTO Invoices(Invoice_ID, User_ID, Booking_ID, Issued_Date)
VALUES('I100','U001','B100',NOW());

SELECT * FROM Invoices WHERE Invoice_ID = 'I100';

-- TEST TRIGGER CHECKOUT
UPDATE Bookings
SET Status = 'completed'
WHERE Booking_ID = 'B100';

SELECT * FROM Rooms WHERE Room_ID = 'R003';


-- Stored procdure 
DELIMITER //

DROP PROCEDURE IF EXISTS sp_create_invoice;

CREATE PROCEDURE sp_create_invoice(
    IN p_booking_id VARCHAR(255),
    IN p_user_id VARCHAR(255)
)
BEGIN
    DECLARE total DECIMAL(18,2);

    -- Tính tiền sử dụng function đã có
    SET total = calculate_total(p_booking_id);

    -- Insert hóa đơn
    INSERT INTO Invoices(Invoice_ID, Booking_ID, User_ID, Total_Amount, Issued_Date)
    VALUES (CONCAT('INV', LPAD(FLOOR(RAND()*10000), 4, '0')), p_booking_id, p_user_id, total, NOW());

END //

DELIMITER ;

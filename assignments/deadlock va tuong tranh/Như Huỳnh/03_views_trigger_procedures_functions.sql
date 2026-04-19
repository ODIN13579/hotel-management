USE hotel_management;

-- VIEW
-- chức năng 4:
drop view if exists  vw_services_list;
CREATE OR REPLACE VIEW vw_services_list AS
SELECT 
    Service_ID,
    Name,
    Description,
    Price
FROM Services;

select * from vw_services_list;

-- chức năng 5:
drop view if exists vw_invoice_detail;
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

select * from vw_invoice_detail;


-- function 
-- CHỨC NĂNG phụ: Tính tiền (dùng cho trigger 5)
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

    RETURN IFNULL(total, 0);
END //

DELIMITER ;


/*=========================================================
===========================================================*/

-- CHỨC NĂNG 5: Trigger tính tiền hóa đơn
DROP TRIGGER IF EXISTS trg_invoice_total;

DELIMITER //

CREATE TRIGGER trg_invoice_total
BEFORE INSERT ON Invoices
FOR EACH ROW
BEGIN
    SET NEW.Total_Amount = calculate_total(NEW.Booking_ID);
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
-- CHỨC NĂNG 6: Ghi nhận giao dịch
DROP PROCEDURE IF EXISTS sp_record_transaction;

DELIMITER //

CREATE PROCEDURE sp_record_transaction(
    IN p_booking_id VARCHAR(255),
    IN p_user_id VARCHAR(255),
    IN p_payment_method VARCHAR(50)
)
BEGIN
    DECLARE v_invoice_id VARCHAR(255);
    DECLARE v_total DECIMAL(18,2);

    -- Tạo mã hóa đơn
    SET v_invoice_id = CONCAT('INV', LPAD(FLOOR(RAND()*10000), 4, '0'));

    -- Tạo invoice (trigger sẽ tự tính total)
    INSERT INTO Invoices(Invoice_ID, Booking_ID, User_ID, Issued_Date)
    VALUES (v_invoice_id, p_booking_id, p_user_id, NOW());

    -- LẤY LẠI TOTAL (QUAN TRỌNG)
    SELECT Total_Amount INTO v_total
    FROM Invoices
    WHERE Invoice_ID = v_invoice_id;


    -- Ghi nhận thanh toán
    INSERT INTO Payment(
    Payment_ID,
    Booking_ID,
    Amount,
    Payment_Method,
    Payment_Date,
    Status
)
	VALUES (
    CONCAT('PAY', LPAD(FLOOR(RAND()*10000), 4, '0')),
    p_booking_id,
    v_total,
    p_payment_method,
    NOW(),
    'paid'
);

END //

DELIMITER ;

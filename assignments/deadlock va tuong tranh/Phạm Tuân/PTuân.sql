USE hotel_management;
-- FUNCTION
DROP FUNCTION IF EXISTS fn_checkout_total;

DELIMITER //
CREATE FUNCTION fn_checkout_total(p_booking_id VARCHAR(50))
RETURNS DECIMAL(18,2)
DETERMINISTIC
BEGIN
    DECLARE v_total DECIMAL(18,2);

    SELECT IFNULL(b.Room_Deposit,0) + IFNULL(p.Amount,0)
    INTO v_total
    FROM Bookings b
    LEFT JOIN Payment p ON p.Booking_ID = b.Booking_ID
    WHERE b.Booking_ID = p_booking_id;

    RETURN IFNULL(v_total,0);
END //
DELIMITER ;


-- VIEW
CREATE OR REPLACE VIEW vw_checkout_result AS
SELECT 
    b.Booking_ID,
    b.Status AS Booking_Status,
    p.Status AS Payment_Status,
    i.Invoice_ID,
    r.Room_Number,
    r.Status AS Room_Status,
    e.Employee_ID,
    e.Status AS Employee_Status
FROM Bookings b
LEFT JOIN Payment p ON p.Booking_ID = b.Booking_ID
LEFT JOIN Invoices i ON i.Booking_ID = b.Booking_ID
LEFT JOIN Rooms r ON r.Room_ID = b.Room_ID
LEFT JOIN Employees e ON e.Employee_ID = b.Employee_ID;


-- TRIGGER
DROP TRIGGER IF EXISTS trg_auto_invoice_after_payment;
DROP TRIGGER IF EXISTS trg_review_after_checkout;

DELIMITER //

-- Thanh toan thanh cong -> tu tao invoice
CREATE TRIGGER trg_auto_invoice_after_payment
AFTER UPDATE ON Payment
FOR EACH ROW
BEGIN
    DECLARE v_user_id VARCHAR(50);

    IF NEW.Status = 'successful' AND OLD.Status <> 'successful' THEN
        SELECT User_ID INTO v_user_id
        FROM Bookings
        WHERE Booking_ID = NEW.Booking_ID;

        INSERT INTO Invoices(Invoice_ID, User_ID, Booking_ID, Total_Amount, Issued_Date)
        SELECT CONCAT('INV_', NEW.Booking_ID), v_user_id, NEW.Booking_ID,
               fn_checkout_total(NEW.Booking_ID), NOW()
        FROM DUAL
        WHERE NOT EXISTS (
            SELECT 1 FROM Invoices WHERE Booking_ID = NEW.Booking_ID
        );
    END IF;
END //

-- Review chi hop le sau checked_out
CREATE TRIGGER trg_review_after_checkout
BEFORE INSERT ON Reviews
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(50);

    SELECT Status INTO v_status
    FROM Bookings
    WHERE Booking_ID = NEW.Booking_ID;

    IF v_status <> 'checked_out' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Booking chua checked_out, khong the review';
    END IF;
END //

DELIMITER ;


-- PROCEDURE
DROP PROCEDURE IF EXISTS sp_checkout_flow;

DELIMITER //
CREATE PROCEDURE sp_checkout_flow(
    IN p_booking_id VARCHAR(50),
    IN p_payment_method VARCHAR(100)
)
BEGIN
    DECLARE v_room_id VARCHAR(50);
    DECLARE v_employee_id VARCHAR(50);

    SELECT Room_ID, Employee_ID
    INTO v_room_id, v_employee_id
    FROM Bookings
    WHERE Booking_ID = p_booking_id;

    -- 1. da tra phong
    UPDATE Bookings
    SET Status = 'checked_out'
    WHERE Booking_ID = p_booking_id;

    -- 2. thanh toan thanh cong
    UPDATE Payment
    SET Status = 'successful',
        Payment_Method = p_payment_method,
        Payment_Date = NOW()
    WHERE Booking_ID = p_booking_id;

    -- 3 + 4. invoice + phong trong
    UPDATE Rooms
    SET Status = 'available'
    WHERE Room_ID = v_room_id;

    -- 5. cap nhat lai trang thai nhan vien
    UPDATE Employees
    SET Status = 'available'
    WHERE Employee_ID = v_employee_id;

    -- 6. xem ket qua flow, luc nay booking da duoc review
    SELECT *
    FROM vw_checkout_result
    WHERE Booking_ID = p_booking_id;
END //
DELIMITER ;

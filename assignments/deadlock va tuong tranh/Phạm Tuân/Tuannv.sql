USE hotel_management;

-- VIEW
-- Chuc nang 11: view goc cho bao cao doanh thu + dat phong
CREATE OR REPLACE VIEW vw_booking_report AS
SELECT 
    b.Booking_ID,
    b.User_ID,
    b.Room_ID,
    b.Employee_ID,
    b.Booking_Date,
    b.Check_In,
    b.Check_Out,
    b.Status AS Booking_Status,
    IFNULL(b.Room_Deposit,0) AS Room_Deposit,
    IFNULL(p.Amount,0) AS Payment_Amount,
    IFNULL(b.Room_Deposit,0) + IFNULL(p.Amount,0) AS Revenue
FROM Bookings b
LEFT JOIN Payment p ON p.Booking_ID = b.Booking_ID;

-- Chuc nang 12: view goc cho hieu suat phong
CREATE OR REPLACE VIEW vw_room_utilization AS
SELECT 
    r.Room_ID,
    r.Room_Number,
    r.Room_Type,
    b.Booking_ID,
    b.Check_In,
    b.Check_Out,
    b.Status AS Booking_Status,
    DATEDIFF(b.Check_Out, b.Check_In) AS Stay_Days
FROM Rooms r
LEFT JOIN Bookings b ON b.Room_ID = r.Room_ID
WHERE b.Status IN ('confirmed','checked_in','checked_out');


-- FUNCTION
DROP FUNCTION IF EXISTS fn_booking_revenue;
DROP FUNCTION IF EXISTS fn_room_days_in_range;

DELIMITER //

-- Chuc nang 11: doanh thu = payment.amount + booking.room_deposit
CREATE FUNCTION fn_booking_revenue(p_booking_id VARCHAR(50))
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

-- Chuc nang 12: tinh so ngay phong duoc khai thac trong khoang thoi gian
CREATE FUNCTION fn_room_days_in_range(
    p_check_in DATETIME,
    p_check_out DATETIME,
    p_from DATE,
    p_to DATE
)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE v_start DATE;
    DECLARE v_end DATE;

    SET v_start = GREATEST(DATE(p_check_in), p_from);
    SET v_end   = LEAST(DATE(p_check_out), DATE_ADD(p_to, INTERVAL 1 DAY));

    IF v_end <= v_start THEN
        RETURN 0;
    END IF;

    RETURN DATEDIFF(v_end, v_start);
END //

DELIMITER ;

-- TRIGGER
DROP TRIGGER IF EXISTS trg_assign_employee_status;
DROP TRIGGER IF EXISTS trg_review_only_after_checkout;

DELIMITER //

-- Chuc nang 10: da phan cong nhan vien thi doi status nhan vien = processing
CREATE TRIGGER trg_assign_employee_status
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.Employee_ID IS NOT NULL 
       AND (OLD.Employee_ID IS NULL OR OLD.Employee_ID <> NEW.Employee_ID) THEN
        UPDATE Employees
        SET Status = 'processing'
        WHERE Employee_ID = NEW.Employee_ID;
    END IF;
END //

-- Flow review: chi cho review sau khi da tra phong
CREATE TRIGGER trg_review_only_after_checkout
BEFORE INSERT ON Reviews
FOR EACH ROW
BEGIN
    DECLARE v_status VARCHAR(50);

    SELECT Status INTO v_status
    FROM Bookings
    WHERE Booking_ID = NEW.Booking_ID;

    IF v_status <> 'checked_out' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Chi duoc review sau khi da tra phong';
    END IF;
END //

DELIMITER ;


-- STORED PROCEDURE
DROP PROCEDURE IF EXISTS sp_assign_booking;
DROP PROCEDURE IF EXISTS sp_report_revenue_month;
DROP PROCEDURE IF EXISTS sp_report_revenue_week;
DROP PROCEDURE IF EXISTS sp_room_utilization;

DELIMITER //

-- Chuc nang 10: phan cong xu ly dat phong
CREATE PROCEDURE sp_assign_booking(
    IN p_booking_id VARCHAR(50),
    IN p_employee_id VARCHAR(50)
)
BEGIN
    UPDATE Bookings
    SET Employee_ID = p_employee_id,
        Status = 'confirmed'
    WHERE Booking_ID = p_booking_id;

    UPDATE Rooms
    SET Status = 'booked'
    WHERE Room_ID = (SELECT Room_ID FROM Bookings WHERE Booking_ID = p_booking_id);

    UPDATE Payment
    SET Status = 'pending'
    WHERE Booking_ID = p_booking_id;
END //

-- Chuc nang 11: bao cao doanh thu theo thang
CREATE PROCEDURE sp_report_revenue_month()
BEGIN
    SELECT 
        YEAR(Booking_Date) AS Report_Year,
        MONTH(Booking_Date) AS Report_Month,
        COUNT(Booking_ID) AS Total_Bookings,
        SUM(Revenue) AS Total_Revenue
    FROM vw_booking_report
    GROUP BY YEAR(Booking_Date), MONTH(Booking_Date)
    ORDER BY Report_Year, Report_Month;
END //

-- Chuc nang 11: bao cao doanh thu theo tuan
CREATE PROCEDURE sp_report_revenue_week()
BEGIN
    SELECT 
        YEAR(Booking_Date) AS Report_Year,
        WEEK(Booking_Date, 1) AS Report_Week,
        COUNT(Booking_ID) AS Total_Bookings,
        SUM(Revenue) AS Total_Revenue
    FROM vw_booking_report
    GROUP BY YEAR(Booking_Date), WEEK(Booking_Date, 1)
    ORDER BY Report_Year, Report_Week;
END //

-- Chuc nang 12: hieu suat khai thac phong trong 1 khoang ngay
CREATE PROCEDURE sp_room_utilization(
    IN p_from DATE,
    IN p_to DATE
)
BEGIN
    SELECT 
        r.Room_ID,
        r.Room_Number,
        SUM(fn_room_days_in_range(b.Check_In, b.Check_Out, p_from, p_to)) AS Used_Days,
        DATEDIFF(DATE_ADD(p_to, INTERVAL 1 DAY), p_from) AS Period_Days,
        ROUND(
            SUM(fn_room_days_in_range(b.Check_In, b.Check_Out, p_from, p_to))
            / DATEDIFF(DATE_ADD(p_to, INTERVAL 1 DAY), p_from) * 100, 2
        ) AS Utilization_Rate
    FROM Rooms r
    LEFT JOIN Bookings b ON b.Room_ID = r.Room_ID
        AND b.Status IN ('confirmed','checked_in','checked_out')
    GROUP BY r.Room_ID, r.Room_Number
    ORDER BY r.Room_Number;
END //

DELIMITER ;


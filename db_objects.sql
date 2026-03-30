USE hotel_management;

CREATE INDEX idx_bookings_employee_id ON Bookings(Employee_ID);
CREATE INDEX idx_bookings_booking_date ON Bookings(Booking_Date);
CREATE INDEX idx_bookings_checkin_checkout ON Bookings(Check_In, Check_Out);
CREATE INDEX idx_bookings_status ON Bookings(Status);
CREATE INDEX idx_payment_payment_date ON Payment(Payment_Date);
CREATE INDEX idx_payment_status ON Payment(Status);

DROP VIEW IF EXISTS vw_booking_assignment;
DROP VIEW IF EXISTS vw_monthly_revenue_bookings;
DROP VIEW IF EXISTS vw_weekly_revenue_bookings;
DROP VIEW IF EXISTS vw_room_booking_nights;
DROP TRIGGER IF EXISTS trg_before_update_booking_assignment;
DROP TRIGGER IF EXISTS trg_after_update_booking_assignment;

DROP PROCEDURE IF EXISTS sp_assign_employee_to_booking;
DROP PROCEDURE IF EXISTS sp_report_monthly_revenue_bookings;
DROP PROCEDURE IF EXISTS sp_report_weekly_revenue_bookings;
DROP PROCEDURE IF EXISTS sp_room_utilization_report;

DROP FUNCTION IF EXISTS fn_booking_nights;
DROP FUNCTION IF EXISTS fn_room_utilization_percent;

/* -------------------------
   VIEW - Task 10
   Assignment overview
   ------------------------- */
CREATE VIEW vw_booking_assignment AS
SELECT
    b.Booking_ID,
    b.Booking_Date,
    b.Check_In,
    b.Check_Out,
    b.Status AS Booking_Status,
    u.User_ID,
    u.Name AS Customer_Name,
    u.Phone AS Customer_Phone,
    r.Room_ID,
    r.Room_Number,
    r.RoomType,
    r.Status AS Room_Status,
    e.Employee_ID,
    e.Name AS Employee_Name,
    e.Role AS Employee_Role,
    e.Status AS Employee_Status
FROM Bookings b
JOIN Users u ON b.User_ID = u.User_ID
JOIN Rooms r ON b.Room_ID = r.Room_ID
LEFT JOIN Employees e ON b.Employee_ID = e.Employee_ID;

/* -------------------------
   VIEW - Task 11
   Monthly report summary
   ------------------------- */
CREATE VIEW vw_monthly_revenue_bookings AS
SELECT
    YEAR(p.Payment_Date) AS Report_Year,
    MONTH(p.Payment_Date) AS Report_Month,
    COUNT(DISTINCT p.Booking_ID) AS Total_Paid_Bookings,
    COALESCE(SUM(p.Amount), 0) AS Total_Revenue
FROM Payment p
WHERE LOWER(COALESCE(p.Status, '')) = 'paid'
GROUP BY YEAR(p.Payment_Date), MONTH(p.Payment_Date);

/* -------------------------
   VIEW - Task 11
   Weekly report summary
   Mode 1: week starts Monday
   ------------------------- */
CREATE VIEW vw_weekly_revenue_bookings AS
SELECT
    YEAR(p.Payment_Date) AS Report_Year,
    WEEK(p.Payment_Date, 1) AS Report_Week,
    YEARWEEK(p.Payment_Date, 1) AS Year_Week_Key,
    COUNT(DISTINCT p.Booking_ID) AS Total_Paid_Bookings,
    COALESCE(SUM(p.Amount), 0) AS Total_Revenue
FROM Payment p
WHERE LOWER(COALESCE(p.Status, '')) = 'paid'
GROUP BY YEAR(p.Payment_Date), WEEK(p.Payment_Date, 1), YEARWEEK(p.Payment_Date, 1);

/* -------------------------
   FUNCTION - Common helper
   Booking nights
   ------------------------- */
DELIMITER $$
CREATE FUNCTION fn_booking_nights(p_booking_id VARCHAR(50))
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE v_nights INT DEFAULT 0;

    SELECT
        CASE
            WHEN Check_In IS NULL OR Check_Out IS NULL OR Check_Out <= Check_In THEN 0
            ELSE DATEDIFF(DATE(Check_Out), DATE(Check_In))
        END
    INTO v_nights
    FROM Bookings
    WHERE Booking_ID = p_booking_id
    LIMIT 1;

    RETURN COALESCE(v_nights, 0);
END $$
DELIMITER ;

/* -------------------------
   VIEW - Task 12
   Booking nights per room
   ------------------------- */
CREATE VIEW vw_room_booking_nights AS
SELECT
    b.Booking_ID,
    b.Room_ID,
    r.Room_Number,
    r.RoomType,
    b.Check_In,
    b.Check_Out,
    fn_booking_nights(b.Booking_ID) AS Nights_Used,
    b.Status AS Booking_Status
FROM Bookings b
JOIN Rooms r ON b.Room_ID = r.Room_ID
WHERE LOWER(COALESCE(b.Status, '')) IN ('confirmed', 'checked_in', 'completed');

/* -------------------------
   FUNCTION - Task 12
   Utilization percent of 1 room in a date range
   ------------------------- */
DELIMITER $$
CREATE FUNCTION fn_room_utilization_percent(
    p_room_id VARCHAR(50),
    p_start_date DATE,
    p_end_date DATE
)
RETURNS DECIMAL(8,2)
READS SQL DATA
BEGIN
    DECLARE v_total_days INT DEFAULT 0;
    DECLARE v_occupied_days INT DEFAULT 0;

    IF p_start_date IS NULL OR p_end_date IS NULL OR p_end_date < p_start_date THEN
        RETURN 0.00;
    END IF;

    SET v_total_days = DATEDIFF(DATE_ADD(p_end_date, INTERVAL 1 DAY), p_start_date);

    SELECT COALESCE(SUM(
        GREATEST(
            0,
            DATEDIFF(
                LEAST(DATE(Check_Out), DATE_ADD(p_end_date, INTERVAL 1 DAY)),
                GREATEST(DATE(Check_In), p_start_date)
            )
        )
    ), 0)
    INTO v_occupied_days
    FROM Bookings
    WHERE Room_ID = p_room_id
      AND LOWER(COALESCE(Status, '')) IN ('confirmed', 'checked_in', 'completed')
      AND Check_In < DATE_ADD(p_end_date, INTERVAL 1 DAY)
      AND Check_Out > p_start_date;

    IF v_total_days <= 0 THEN
        RETURN 0.00;
    END IF;

    RETURN ROUND((v_occupied_days / v_total_days) * 100, 2);
END $$
DELIMITER ;

/* -------------------------
   TRIGGER - Task 10
   Validate assignment before update
   ------------------------- */
DELIMITER $$
CREATE TRIGGER trg_before_update_booking_assignment
BEFORE UPDATE ON Bookings
FOR EACH ROW
BEGIN
    DECLARE v_employee_status VARCHAR(50);

    IF NEW.Employee_ID IS NOT NULL AND NOT (OLD.Employee_ID <=> NEW.Employee_ID) THEN
        SELECT Status
        INTO v_employee_status
        FROM Employees
        WHERE Employee_ID = NEW.Employee_ID
        LIMIT 1;

        IF v_employee_status IS NULL THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Employee does not exist.';
        END IF;

        IF LOWER(COALESCE(v_employee_status, '')) <> 'active' THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Only active employees can be assigned to a booking.';
        END IF;

        IF LOWER(COALESCE(OLD.Status, '')) IN ('cancelled', 'completed') THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Cannot assign employee to a cancelled or completed booking.';
        END IF;

        IF LOWER(COALESCE(OLD.Status, '')) = 'pending' THEN
            SET NEW.Status = 'confirmed';
        END IF;
    END IF;
END $$
DELIMITER ;

/* -------------------------
   TRIGGER - Task 10
   Notify customer after assignment
   ------------------------- */
DELIMITER $$
CREATE TRIGGER trg_after_update_booking_assignment
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    IF NEW.Employee_ID IS NOT NULL AND NOT (OLD.Employee_ID <=> NEW.Employee_ID) AND NEW.User_ID IS NOT NULL THEN
        INSERT INTO Notifications (
            Notification_ID,
            User_ID,
            Message,
            Sent_Date,
            Is_Read
        )
        VALUES (
            CONCAT('NOTI_', REPLACE(UUID(), '-', '')),
            NEW.User_ID,
            CONCAT('Booking ', NEW.Booking_ID, ' has been assigned to employee ', NEW.Employee_ID, '.'),
            NOW(),
            FALSE
        );
    END IF;
END $$
DELIMITER ;

/* -------------------------
   STORED PROCEDURE - Task 10
   Assign employee to booking
   ------------------------- */
DELIMITER $$
CREATE PROCEDURE sp_assign_employee_to_booking(
    IN p_booking_id VARCHAR(50),
    IN p_employee_id VARCHAR(50)
)
BEGIN
    DECLARE v_booking_exists INT DEFAULT 0;
    DECLARE v_employee_exists INT DEFAULT 0;
    DECLARE v_booking_status VARCHAR(50);
    DECLARE v_employee_status VARCHAR(50);

    SELECT COUNT(*), MAX(Status)
    INTO v_booking_exists, v_booking_status
    FROM Bookings
    WHERE Booking_ID = p_booking_id;

    IF v_booking_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Booking does not exist.';
    END IF;

    SELECT COUNT(*), MAX(Status)
    INTO v_employee_exists, v_employee_status
    FROM Employees
    WHERE Employee_ID = p_employee_id;

    IF v_employee_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee does not exist.';
    END IF;

    IF LOWER(COALESCE(v_employee_status, '')) <> 'active' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee is not active.';
    END IF;

    IF LOWER(COALESCE(v_booking_status, '')) IN ('cancelled', 'completed') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Booking is cancelled or completed, cannot assign.';
    END IF;

    UPDATE Bookings
    SET Employee_ID = p_employee_id
    WHERE Booking_ID = p_booking_id;

    SELECT 'Assign employee successfully.' AS Message,
           p_booking_id AS Booking_ID,
           p_employee_id AS Employee_ID;
END $$
DELIMITER ;

/* -------------------------
   STORED PROCEDURE - Task 11
   Monthly report: revenue + bookings
   ------------------------- */
DELIMITER $$
CREATE PROCEDURE sp_report_monthly_revenue_bookings(IN p_year INT)
BEGIN
    WITH RECURSIVE months AS (
        SELECT 1 AS report_month
        UNION ALL
        SELECT report_month + 1
        FROM months
        WHERE report_month < 12
    ),
    booking_data AS (
        SELECT
            MONTH(Booking_Date) AS report_month,
            COUNT(*) AS total_bookings
        FROM Bookings
        WHERE YEAR(Booking_Date) = p_year
        GROUP BY MONTH(Booking_Date)
    ),
    payment_data AS (
        SELECT
            MONTH(Payment_Date) AS report_month,
            COUNT(*) AS total_paid_bookings,
            COALESCE(SUM(Amount), 0) AS total_revenue
        FROM Payment
        WHERE YEAR(Payment_Date) = p_year
          AND LOWER(COALESCE(Status, '')) = 'paid'
        GROUP BY MONTH(Payment_Date)
    )
    SELECT
        p_year AS Report_Year,
        m.report_month AS Report_Month,
        COALESCE(b.total_bookings, 0) AS Total_Bookings,
        COALESCE(p.total_paid_bookings, 0) AS Total_Paid_Bookings,
        COALESCE(p.total_revenue, 0) AS Total_Revenue
    FROM months m
    LEFT JOIN booking_data b ON m.report_month = b.report_month
    LEFT JOIN payment_data p ON m.report_month = p.report_month
    ORDER BY m.report_month;
END $$
DELIMITER ;

/* -------------------------
   STORED PROCEDURE - Task 11
   Weekly report: revenue + bookings
   Mode 1: week starts Monday
   ------------------------- */
DELIMITER $$
CREATE PROCEDURE sp_report_weekly_revenue_bookings(IN p_year INT)
BEGIN
    WITH RECURSIVE weeks AS (
        SELECT 1 AS report_week
        UNION ALL
        SELECT report_week + 1
        FROM weeks
        WHERE report_week < 53
    ),
    booking_data AS (
        SELECT
            WEEK(Booking_Date, 1) AS report_week,
            COUNT(*) AS total_bookings
        FROM Bookings
        WHERE YEAR(Booking_Date) = p_year
        GROUP BY WEEK(Booking_Date, 1)
    ),
    payment_data AS (
        SELECT
            WEEK(Payment_Date, 1) AS report_week,
            COUNT(*) AS total_paid_bookings,
            COALESCE(SUM(Amount), 0) AS total_revenue
        FROM Payment
        WHERE YEAR(Payment_Date) = p_year
          AND LOWER(COALESCE(Status, '')) = 'paid'
        GROUP BY WEEK(Payment_Date, 1)
    )
    SELECT
        p_year AS Report_Year,
        w.report_week AS Report_Week,
        COALESCE(b.total_bookings, 0) AS Total_Bookings,
        COALESCE(p.total_paid_bookings, 0) AS Total_Paid_Bookings,
        COALESCE(p.total_revenue, 0) AS Total_Revenue
    FROM weeks w
    LEFT JOIN booking_data b ON w.report_week = b.report_week
    LEFT JOIN payment_data p ON w.report_week = p.report_week
    ORDER BY w.report_week;
END $$
DELIMITER ;

/* -------------------------
   STORED PROCEDURE - Task 12
   Room utilization report by date range
   ------------------------- */
DELIMITER $$
CREATE PROCEDURE sp_room_utilization_report(
    IN p_start_date DATE,
    IN p_end_date DATE
)
BEGIN
    IF p_start_date IS NULL OR p_end_date IS NULL OR p_end_date < p_start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid date range.';
    END IF;

    SELECT
        r.Room_ID,
        r.Room_Number,
        r.RoomType,
        r.Status AS Room_Status,
        COALESCE(SUM(
            CASE
                WHEN b.Booking_ID IS NULL THEN 0
                ELSE GREATEST(
                    0,
                    DATEDIFF(
                        LEAST(DATE(b.Check_Out), DATE_ADD(p_end_date, INTERVAL 1 DAY)),
                        GREATEST(DATE(b.Check_In), p_start_date)
                    )
                )
            END
        ), 0) AS Occupied_Days,
        DATEDIFF(DATE_ADD(p_end_date, INTERVAL 1 DAY), p_start_date) AS Period_Days,
        fn_room_utilization_percent(r.Room_ID, p_start_date, p_end_date) AS Utilization_Percent
    FROM Rooms r
    LEFT JOIN Bookings b
        ON r.Room_ID = b.Room_ID
       AND LOWER(COALESCE(b.Status, '')) IN ('confirmed', 'checked_in', 'completed')
       AND b.Check_In < DATE_ADD(p_end_date, INTERVAL 1 DAY)
       AND b.Check_Out > p_start_date
    GROUP BY r.Room_ID, r.Room_Number, r.RoomType, r.Status
    ORDER BY Utilization_Percent DESC, r.Room_Number;
END $$
DELIMITER ;

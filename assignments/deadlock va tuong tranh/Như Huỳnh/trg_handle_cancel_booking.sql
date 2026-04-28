USE hotel_management;

DROP TRIGGER IF EXISTS trg_cancel_booking;

DELIMITER //

CREATE TRIGGER trg_cancel_booking
AFTER UPDATE ON Bookings
FOR EACH ROW
BEGIN
    -- chỉ xử lý khi chuyển từ confirmed / checked_in → cancelled
    IF NEW.Status = 'cancelled' 
       AND OLD.Status IN ('confirmed','checked_in') THEN
        
        -- 1. cập nhật phòng → available
        UPDATE Rooms
        SET Status = 'available'
        WHERE Room_ID = NEW.Room_ID;

        -- 2. cập nhật payment → failed
       -- nếu đã có payment → update
		IF EXISTS (
			SELECT 1 FROM Payment 
			WHERE Booking_ID = NEW.Booking_ID
		) THEN
			UPDATE Payment
			SET Status = 'failed'
			WHERE Booking_ID = NEW.Booking_ID;

		ELSE
			-- nếu chưa có → insert
			INSERT INTO Payment (
				Payment_ID,
				Booking_ID,
				Amount,
				Payment_Date,
				Payment_Method,
				Status
			)
			VALUES (
				CONCAT('P', UUID()),
				NEW.Booking_ID,
				0,
				NOW(),
				'unknown',
				'failed'
			);
		END IF;

        -- 3. xử lý refund (KHÔNG duplicate)
        IF NOT EXISTS (
            SELECT 1 FROM CancellationRefund
            WHERE Booking_ID = NEW.Booking_ID
        ) THEN
            INSERT INTO CancellationRefund(
                CancellationRefund_ID,
                Booking_ID,
                Cancellation_Date,
                Refund_Amount,
                Status
            )
            VALUES (
                CONCAT('CR', UUID()),
                NEW.Booking_ID,
                NOW(),
                0,
                'no_refund'
            );
        END IF;

        -- 4. gửi notification (KHÔNG duplicate)
        IF NOT EXISTS (
            SELECT 1 FROM Notifications
            WHERE User_ID = NEW.User_ID
              AND Message = 'Your booking has been cancelled. Deposit is lost.'
        ) THEN
            INSERT INTO Notifications (
                Notification_ID,
                User_ID,
                Message,
                Sent_Date,
                Is_Read
            )
            VALUES (
                CONCAT('N', UUID()),
                NEW.User_ID,
                'Your booking has been cancelled. Deposit is lost.',
                NOW(),
                0
            );
        END IF;

        -- 5. cập nhật nhân viên → available
        IF NEW.Employee_ID IS NOT NULL THEN
            UPDATE Employees
            SET Status = 'available'
            WHERE Employee_ID = NEW.Employee_ID;
        END IF;

    END IF;
END //

DELIMITER ;

-- ===========================================================================
-- test 
-- 1. kiểm tra trước khi update
SELECT * FROM Bookings WHERE Booking_ID = 'B005';
SELECT * FROM Rooms WHERE Room_ID = 'R001';

-- reset trạng thái
UPDATE Bookings
SET Status = 'confirmed'
WHERE Booking_ID = 'B005';

-- 2. chạy trigger
UPDATE Bookings
SET Status = 'cancelled'
WHERE Booking_ID = 'B005';


-- 3. kiểm tra lại booking
SELECT Booking_ID, Status 
FROM Bookings 
WHERE Booking_ID = 'B005';

-- 4. kiểm tra phòng (PHẢI = available)
SELECT Room_ID, Status 
FROM Rooms 
WHERE Room_ID = 'R001';

-- 5. kiểm tra payment (nếu có)
SELECT * 
FROM Payment 
WHERE Booking_ID = 'B005';

-- 6. kiểm tra refund
SELECT * 
FROM CancellationRefund 
WHERE Booking_ID = 'B005';

-- 7. kiểm tra notification (PHẢI có)
SELECT * 
FROM Notifications 
ORDER BY Sent_Date DESC;
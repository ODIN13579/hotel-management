USE hotel_management;

-- DEADLOCK

-- T1
BEGIN TRAN

-- khóa phòng trước
UPDATE Rooms
SET status = 'Booked'
WHERE room_id = 1

WAITFOR DELAY '00:00:05'

-- sau đó tạo booking
INSERT INTO Bookings (booking_id, room_id, status)
VALUES (2, 1, 'Pending')

COMMIT


-- T2
BEGIN TRAN

-- khóa booking trước
UPDATE Bookings
SET status = 'Completed'
WHERE booking_id = 1

WAITFOR DELAY '00:00:05'

-- sau đó cập nhật phòng
UPDATE Rooms
SET status = 'Available'
WHERE room_id = 1

COMMIT
----------------------------------------------------- 

-- LOST UPDATE (Ghi nhận giao dịch)

-- T1
BEGIN TRAN
DECLARE @status1 NVARCHAR(50)

-- đọc trạng thái
SELECT @status1 = status
FROM Bookings
WHERE booking_id = 1

WAITFOR DELAY '00:00:05'

-- xử lý thanh toán
SET @status1 = 'Completed - T1'

UPDATE Bookings
SET status = @status1
WHERE booking_id = 1

COMMIT


-- T2
BEGIN TRAN
DECLARE @status2 NVARCHAR(50)

-- đọc trạng thái
SELECT @status2 = status
FROM Bookings
WHERE booking_id = 1

-- xử lý thanh toán
SET @status2 = 'Completed - T2'

UPDATE Bookings
SET status = @status2
WHERE booking_id = 1

COMMIT

--------------------------------------------------------------------------

-- PHANTOM READ

-- T1 (xem danh sách dịch vụ)
SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT * FROM Services;  -- lần 1 (3 dòng)

SELECT SLEEP(5);

SELECT * FROM Services;  -- lần 2 (4 dòng)

COMMIT;


-- T2 (thêm dịch vụ mới)
SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT SLEEP(2);

INSERT INTO Services(service_id, service_name)
VALUES ('S4', 'Giặt ủi');

COMMIT;
------------------------------------------------------------------------------

-- NON-REPEATABLE(KHÔNG ĐỌC DỮ LIỆU)

-- T1 (Customer xem hóa đơn)
SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT total_amount FROM Bills WHERE bill_id = 'B1'; -- 1.000.000

SELECT SLEEP(5);

SELECT total_amount FROM Bills WHERE bill_id = 'B1'; -- 1.200.000

COMMIT;


-- T2 (Admin sửa giá)
SET autocommit = 0;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT SLEEP(2);

UPDATE Bills
SET total_amount = total_amount + 200000
WHERE bill_id = 'B1';

COMMIT;

------------------------------------------------------------------------

-- DIRTY WRITE (MÔ PHỎNG)

-- T1: Lễ tân sửa hóa đơn
BEGIN TRAN

UPDATE Bills
SET total_amount = 1000000
WHERE bill_id = 'B1'

-- chưa commit


-- T2: Admin ghi đè khi T1 chưa commit (GIẢ LẬP)
BEGIN TRAN

UPDATE Bills
SET total_amount = 1200000
WHERE bill_id = 'B1'

COMMIT


-- T1 hủy thay đổi
ROLLBACK
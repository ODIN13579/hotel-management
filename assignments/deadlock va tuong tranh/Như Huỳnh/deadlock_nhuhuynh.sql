USE hotel_management;

-- DEADLOCK

-- T1
START TRANSACTION;

UPDATE Rooms
SET Status = 'Occupied'
WHERE Room_ID = 'R001';

SELECT SLEEP(5);

UPDATE Bookings
SET Status = 'Confirmed'
WHERE Booking_ID = 'B001';

COMMIT;


-- T2
START TRANSACTION;

UPDATE Bookings
SET Status = 'Completed'
WHERE Booking_ID = 'B001';

SELECT SLEEP(5);

UPDATE Rooms
SET Status = 'Available'
WHERE Room_ID = 'R001';

COMMIT;
----------------------------------------------------- 

-- LOST UPDATE (Ghi nhận giao dịch)

-- T1
START TRANSACTION;

-- đọc trạng thái
SELECT Status 
FROM Bookings
WHERE Booking_ID = 'B001';

-- giả lập delay
SELECT SLEEP(5);

-- xử lý
UPDATE Bookings
SET Status = 'Completed - T1'
WHERE Booking_ID = 'B001';

COMMIT;

-- T2
START TRANSACTION;

-- đọc trạng thái
SELECT Status 
FROM Bookings
WHERE Booking_ID = 'B001';

-- xử lý
UPDATE Bookings
SET Status = 'Completed - T2'
WHERE Booking_ID = 'B001';

COMMIT;

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

INSERT INTO Services(Service_ID, Name)
VALUES ('S004', 'Giặt ủi');

COMMIT;
------------------------------------------------------------------------------

-- NON-REPEATABLE(KHÔNG ĐỌC DỮ LIỆU)

-- T1
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;

START TRANSACTION;

SELECT Total_Amount FROM Invoices WHERE Invoice_ID = 'I001';

SELECT SLEEP(5);

SELECT Total_Amount FROM Invoices WHERE Invoice_ID = 'I001';

COMMIT;


-- T2
START TRANSACTION;

SELECT SLEEP(2);

UPDATE Invoices
SET Total_Amount = Total_Amount + 200000
WHERE Invoice_ID = 'I001';

COMMIT;

------------------------------------------------------------------------

-- DIRTY WRITE (MÔ PHỎNG)

-- T1: Lễ tân sửa hóa đơn
START TRANSACTION;

UPDATE Invoices
SET Total_Amount = 1000000
WHERE Invoice_ID = 'I001';

-- chưa commit → đang giữ lock


-- T2: Admin ghi đè khi T1 chưa commit (GIẢ LẬP)
START TRANSACTION;

UPDATE Invoices
SET Total_Amount = 1200000
WHERE Invoice_ID = 'I001';

--  bị chờ (không chạy tiếp được)

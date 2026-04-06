use [hotel_management]
-- lost update
-- T1
BEGIN TRAN --T1
DECLARE @M1 NVARCHAR(255)
-- đọc thông báo
SELECT @M1 = N.Message from Notifications N
where N.Notification_ID = 'NB1'

SET @M1 = 'DAT PHONG KHONG THANH CONG'
UPDATE Notifications SET Message = @M1
WHERE Notification_ID = 'NB1'

COMMIT

BEGIN TRAN --T2
DECLARE @M2 NVARCHAR(255)

SELECT @M2 = N.Message from Notifications N
where N.Notification_ID = 'NB1'

SET @M2 = 'DAT PHONG KHONG THANH CONG - VUI LONG DAT LAI'
UPDATE Notifications SET Message = @M2
WHERE Notification_ID = 'NB2'

COMMIT

--DIRTY READ
BEGIN TRAN --T1
-- cập nhật thông báo nhưng chưa commit
UPDATE Notifications
SET Message = 'DAT PHONG KHONG THANH CONG'
WHERE Notification_ID = 'NB1'
WAITFOR DELAY '00:00:05'

ROLLBACK TRAN 

BEGIN TRAN --T2
SELECT N.Message FROM Notifications N WHERE N.Notification_ID = 'NB1'

COMMIT

---- Non-repeatable Read
BEGIN TRAN -- T1
-- cập nhật thông báo nhưng chưa commit
SELECT * FROM Notifications --T1 đọc lần 1
WHERE Notification_ID = 'NB1'   

WAITFOR DELAY '00:00:05'--

SELECT * FROM Notifications --T1 đọc lần 2
WHERE Notification_ID = 'NB1'  

COMMIT

BEGIN TRAN -- T2
UPDATE Notifications
SET Message = N'Đặt phòng thành công!'
WHERE Notification_ID = 'NB1'

COMMIT

WAITFOR DELAY '00:00:02';  -- đảm bảo chạy giữa T1
--T2 cập nhật thông báo trong khi T1 đang đọc, dẫn đến non-repeatable read khi T1 đọc lại sau khi T2 đã cập nhật
BEGIN TRAN

UPDATE Notifications
SET Message = N'Đặt phòng thành công'
WHERE Notification_ID = 'NB1';

COMMIT


--deadlock
BEGIN TRAN

UPDATE Rooms
SET Status = N'Đã đặt'
WHERE Room_ID = 'R001';   -- giữ rooms khóa dòng rooms lại

WAITFOR DELAY '00:00:05';

UPDATE Employees
SET Status = N'Processing'
WHERE Employee_ID = 'E001';  -- cần employess để cập nhật nhma T2 đang giữ khóa

COMMIT

BEGIN TRAN

UPDATE Employees
SET Status = N'Processing'
WHERE Employee_ID = 'E001';  -- giữ Employees khóa dòng Employees lại

WAITFOR DELAY '00:00:05';

UPDATE Rooms
SET Status = N'Đã đặt'
WHERE Room_ID = 'R001';  -- cần rooms để cập nhật nhưng T1 đang giữ khóa

COMMIT
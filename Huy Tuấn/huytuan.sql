use [hotel_management]

BEGIN TRAN --T1
DECLARE @M1 NVARCHAR(255)

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

SELECT * FROM Notifications
WHERE Notification_ID = 'NB1'   

WAITFOR DELAY '00:00:05'

SELECT * FROM Notifications
WHERE Notification_ID = 'NB1'  

COMMIT

BEGIN TRAN -- T2

UPDATE Notifications
SET Message = N'Đặt phòng thành công!'
WHERE Notification_ID = 'NB1'

COMMIT
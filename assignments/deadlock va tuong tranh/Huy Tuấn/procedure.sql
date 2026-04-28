-- chức năng 8
-- tạo produce để gửi thông báo cho người dùng
CREATE PROCEDURE SP_gui_Notification
    @Notification_ID VARCHAR(50),
    @User_ID VARCHAR(50),
    @Message NVARCHAR(1000)
AS
BEGIN
    INSERT INTO Notifications (Notification_ID, User_ID, Message)
    VALUES (@Notification_ID, @User_ID, @Message);
END
-- tạo trigger ở đây
USE hotel_management;
-- xóa trigger nếu đã tồn tại

-- viet code tạo trigger ở đây

-- chức năng 8
-- tạo trigger để tự động gửi thông báo khi đặt phòng
CREATE TRIGGER TRG_NotifyBooking
ON Bookings
AFTER INSERT
AS
BEGIN
    INSERT INTO Notifications (Notification_ID, User_ID, Message)
    SELECT 
        CONCAT('N', I.Booking_ID),
        I.User_ID,
        N'Đặt phòng thành công!'
    FROM INSERTED I;
END
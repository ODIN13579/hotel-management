-- chức năng 8
-- tạo trigger để tự động gửi thông báo khi có đã xác nhận booking 
CREATE TRIGGER TRG_NotifyBooking
ON Bookings
AFTER INSERT, UPDATE
AS
BEGIN
    INSERT INTO Notifications (Notification_ID, User_ID, Message)
    SELECT 
    -- CONCAT để tạo ID thông báo duy nhất dựa trên Booking_ID
        CONCAT('N', I.Booking_ID),
        I.User_ID,
        N'Đặt phòng thành công!'
    FROM INSERTED I
    WHERE I.Status = N'Confirmed';
END


-- chức năng liên kết số 1
-- tạo trigger để tự động cập nhật trạng thái phòng khi đã xác nhận booking
CREATE TRIGGER TRG_UpdateRoomStatus
ON Bookings
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Rooms R
    SET R.Status = N'Booked'
    FROM Rooms R
    -- JOIN với bảng tạm Bookings để lấy thông tin về phòng đã được đặt
    JOIN INSERTED I ON R.Room_ID = I.Room_ID
    WHERE I.Status = N'Confirmed';
END


--tạo trigger để tự động cập nhật trạng thái payment ( đang chờ xử lý) khi đã xác nhận booking
CREATE TRIGGER TRG_UpdatePaymentStatus
ON Bookings
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Payment P 
    SET P.Status = N'Pending'
    FROM Payment P
    -- JOIN với bảng tạm Bookings để lấy thông tin về booking đã được xác nhận
    JOIN INSERTED I ON P.Booking_ID = I.Booking_ID
    WHERE I.Status = N'Confirmed';
END


--tạo trigger để tự động cập nhật trạng thái employee (processing ) khi đã xác nhận booking
CREATE TRIGGER TRG_UpdateEmployeeStatus
ON Bookings
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Employees E 
    SET E.Status = N'Processing'
    FROM Employees E
    -- JOIN với bảng tạm Bookings để lấy thông tin về booking đã được xác nhận
    JOIN INSERTED I ON E.Employee_ID = I.Employee_ID
    WHERE I.Status = N'Confirmed';
END
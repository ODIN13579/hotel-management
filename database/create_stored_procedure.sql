-- tạo các Stored Procedure ở đây
use hotel_management;
-- xóa các Stored Procedure nếu đã tồn tại

-- viet code tạo Stored Procedure ở đây
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

-- 13: Create account
CREATE PROCEDURE CreateAccount (
	@NewUserID VARCHAR(50),
	@NewName VARCHAR(255),
	@NewEmail VARCHAR(255),
	@NewPhone VARCHAR(255),
	@NewPassword VARCHAR(255)
)
AS
BEGIN	

    INSERT INTO [dbo].[Users] ([User_ID], [Name], [Email], [Phone], [Password])
     VALUES(@NewUserID, @NewName, @NewEmail, @NewPhone, @NewPassword)
END
GO

-- 14: Update information of user
CREATE PROCEDURE UpdateInformation (
	@UserID VARCHAR(50),
	@NewName VARCHAR(255),
	@NewEmail VARCHAR(255),
	@NewPhone VARCHAR(255),
	@NewPassword VARCHAR(255)
)
AS
BEGIN	
	UPDATE Users
	SET Name = @NewName,
		Email = @NewEmail,
		Phone = @NewPhone,
		Password = @NewPassword
	WHERE User_ID = @UserID
END
GO

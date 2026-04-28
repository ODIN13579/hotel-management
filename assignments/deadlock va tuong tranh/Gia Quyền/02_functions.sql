-- Function kiem tra tinh trang phong
CREATE FUNCTION fn_KiemTraTrangThaiPhong (@Room_ID VARCHAR(50))
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @CurrentStatus NVARCHAR(50);
    SELECT @CurrentStatus = Status 
    FROM Rooms 
    WHERE Room_ID = @Room_ID;
    
    IF @CurrentStatus IS NULL
        SET @CurrentStatus = N'Không tồn tại';
        
    RETURN @CurrentStatus;
END;
GO
-- 1. SP lay danh sach phong theo tinh trang
CREATE PROCEDURE sp_LayDanhSachPhong
    @StatusFilter NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    IF @StatusFilter IS NULL
        SELECT * FROM vw_DanhSachPhong_ChiTiet;
    ELSE
        SELECT * FROM vw_DanhSachPhong_ChiTiet WHERE Room_Status = @StatusFilter;
END;
GO

-- 2. SP cap nhat trang thai phong
CREATE PROCEDURE sp_CapNhatTrangThaiPhong
    @Room_ID VARCHAR(50),
    @New_Status NVARCHAR(50)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM Rooms WHERE Room_ID = @Room_ID)
    BEGIN
        UPDATE Rooms SET Status = @New_Status WHERE Room_ID = @Room_ID;
        PRINT N'Cập nhật trạng thái phòng thành công!';
    END
    ELSE
    BEGIN
        RAISERROR(N'Lỗi: Không tìm thấy mã phòng này!', 16, 1);
    END
END;
GO
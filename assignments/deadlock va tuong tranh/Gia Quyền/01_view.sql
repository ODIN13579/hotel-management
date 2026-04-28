-- View xem danh sach phong chi tiet
ALTER VIEW vw_DanhSachPhong_ChiTiet AS
SELECT 
    r.Room_ID,
    r.Room_Number,
    r.Room_type, 
    r.Capacity,
    r.Price_Per_Night,
    r.Status AS Room_Status,
    ISNULL(STRING_AGG(s.Name, ', '), N'Không có') AS Included_Services
FROM Rooms r
LEFT JOIN Rooms_Services rs ON r.Room_ID = rs.Room_ID
LEFT JOIN Services s ON rs.Service_ID = s.Service_ID
GROUP BY 
    r.Room_ID, r.Room_Number, r.Room_type, r.Capacity, r.Price_Per_Night, r.Status;
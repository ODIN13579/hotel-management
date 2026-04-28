-- 1. Tự tính tiền hóa đơn
CREATE TRIGGER trg_invoice_total
ON Invoices
AFTER INSERT
AS
BEGIN
    UPDATE Invoices
    SET Total_Amount = dbo.calculate_total(i.Booking_ID)
    FROM Invoices i
    JOIN inserted ins ON i.Invoice_ID = ins.Invoice_ID
END
GO

-- 2. Gán nhân viên → đổi trạng thái
CREATE TRIGGER trg_assign_employee_status
ON Bookings
AFTER UPDATE
AS
BEGIN
    UPDATE Employees
    SET Status = 'processing'
    FROM Employees e
    JOIN inserted i ON e.Employee_ID = i.Employee_ID
END
GO

-- 3. Chỉ được review sau khi checkout
CREATE TRIGGER trg_review_only_after_checkout
ON Reviews
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Bookings b ON i.Booking_ID = b.Booking_ID
        WHERE b.Status <> 'checkedout'
    )
    BEGIN
        RAISERROR('Phai checkout moi duoc review',16,1)
        RETURN
    END

    INSERT INTO Reviews SELECT * FROM inserted
END
GO
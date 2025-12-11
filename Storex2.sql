USE StoreX;
GO

IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleName = N'Admin')
BEGIN
    INSERT INTO Roles (RoleName, Description)
    VALUES (N'Admin', N'Quản trị hệ thống, toàn quyền');
END
GO

DECLARE @AdminRoleID INT;

SELECT @AdminRoleID = RoleID
FROM Roles
WHERE RoleName = N'Admin';

IF NOT EXISTS (SELECT 1 FROM Employees WHERE EmployeeCode = 'EMP_ADMIN')
BEGIN
    INSERT INTO Employees (
        EmployeeCode,
        FullName,
        Position,
        Phone,
        Address,
        Email,
        RoleID,
        IsActive
    )
    VALUES (
        'EMP_ADMIN',                    
        N'Quản trị viên hệ thống',      
        N'Quản trị hệ thống',          
        '0123456789',                   
        N'Hệ thống StoreX',             
        'admin@storex.local',           
        @AdminRoleID,
        1                               
    );
END
GO


DECLARE @EmpID INT;

SELECT @EmpID = EmployeeID
FROM Employees
WHERE EmployeeCode = 'EMP_ADMIN';

-- Nếu chưa có user 'admin' thì tạo mới
IF NOT EXISTS (SELECT 1 FROM Users WHERE Username = 'admin')
BEGIN
    INSERT INTO Users (
        EmployeeID,
        Username,
        PasswordHash,
        PasswordSalt,
        MustChangePassword,
        IsActive,
        CreatedAt
    )
    VALUES (
        @EmpID,                                 
        'admin',                                
        HASHBYTES('SHA2_256', '123456'),        
        NULL,                                   
        0,                                      
        1,                                      
        GETDATE()
    );
END
ELSE
BEGIN
    UPDATE Users
    SET PasswordHash = HASHBYTES('SHA2_256', '123456'),
        IsActive = 1,
        MustChangePassword = 0
    WHERE Username = 'admin';
END
GO

SELECT * FROM Users

USE StoreX;
GO

IF NOT EXISTS (SELECT 1 FROM Roles WHERE RoleName = 'Customer')
BEGIN
    INSERT INTO Roles(RoleName, Description)
    VALUES ('Customer', N'Tài khoản khách hàng');
END
GO

SELECT * FROM Users

SELECT 
    p.ProductID,
    p.ProductCode,
    p.ProductName,
    c.CategoryName,
    p.Unit,
    p.UnitPrice,
    p.CostPrice,
    p.QuantityInStock,
    p.ImagePath,
    p.IsActive,
    p.CreatedAt
FROM Products p
LEFT JOIN Categories c ON p.CategoryID = c.CategoryID
ORDER BY p.CreatedAt DESC;

SELECT 
    CustomerID,
    CustomerCode,
    FullName,
    Phone,
    Address,
    Email,
    IsActive,
    CreatedAt
FROM Customers
ORDER BY CreatedAt DESC;

SELECT 
    u.UserID,
    u.Username,
    u.EmployeeID,
    e.EmployeeCode,
    e.FullName AS EmployeeName,
    r.RoleName,
    u.IsActive,
    u.MustChangePassword,
    u.LastLoginAt,
    u.LastPasswordChange,
    u.CreatedAt
FROM Users u
JOIN Employees e ON u.EmployeeID = e.EmployeeID
JOIN Roles r ON e.RoleID = r.RoleID
ORDER BY u.CreatedAt DESC;

UPDATE Employees
SET RoleID = (SELECT RoleID FROM Roles WHERE RoleName = 'Sales')
WHERE EmployeeCode = 'CUST0002';  -- hoặc EmployeeID tương ứng

INSERT INTO Customers (CustomerCode, FullName, Phone, Address, Email, IsActive, CreatedAt) VALUES
('KH004', N'Nguyễn Văn A', '0912345678', N'Hà Nội', 'nguyenvana@example.com', 1, GETDATE()),
('KH005', N'Trần Thị B', '0987654321', N'Hồ Chí Minh', 'tranthib@example.com', 1, GETDATE()),
('KH006', N'Lê Văn C', '0901122334', N'Đà Nẵng', 'levanc@example.com', 1, GETDATE()),
('KH007', N'Phạm Thị D', '0933445566', N'Hải Phòng', 'phamthid@example.com', 1, GETDATE()),
('KH008', N'Hoàng Văn E', '0977889900', N'Cần Thơ', 'hoangvane@example.com', 1, GETDATE()),
('KH009', N'Vũ Thị F', '0911556677', N'Nghệ An', 'vuthif@example.com', 1, GETDATE()),
('KH010', N'Đặng Văn G', '0944332211', N'Huế', 'dangvang@example.com', 1, GETDATE()),
('KH011', N'Đỗ Thị H', '0966332211', N'Bắc Ninh', 'dothih@example.com', 1, GETDATE()),
('KH012', N'Bùi Văn I', '0388997766', N'Nam Định', 'buivani@example.com', 1, GETDATE()),
('KH013', N'Mai Thị K', '0355667788', N'Thái Bình', 'maithik@example.com', 1, GETDATE()),
('KH014', N'Đinh Văn L', '0324455667', N'Quảng Ninh', 'dinhvanl@example.com', 1, GETDATE()),
('KH015', N'Cao Thị M', '0337788990', N'Bình Dương', 'caothim@example.com', 1, GETDATE()),
('KH016', N'Ngô Văn N', '0345566778', N'Quảng Nam', 'ngovann@example.com', 1, GETDATE()),
('KH017', N'Phan Thị O', '0378899001', N'Khánh Hòa', 'phanthio@example.com', 1, GETDATE()),
('KH018', N'Đào Văn P', '0933445599', N'Vĩnh Phúc', 'daovanp@example.com', 1, GETDATE()),
('KH019', N'Tống Thị Q', '0988223344', N'Hòa Bình', 'tongthiq@example.com', 1, GETDATE()),
('KH020', N'Lương Văn R', '0911998877', N'Hà Tĩnh', 'luongvanr@example.com', 1, GETDATE()),
('KH021', N'Hà Thị S', '0907776655', N'Phú Thọ', 'hathis@example.com', 1, GETDATE()),
('KH022', N'Tạ Văn T', '0922334455', N'Bình Thuận', 'tavant@example.com', 1, GETDATE()),
('KH023', N'La Thị U', '0998877665', N'Tây Ninh', 'lathiu@example.com', 1, GETDATE());


SELECT UserID, Username, PasswordHash, MustChangePassword, IsActive
FROM Users
WHERE Username = 'admin';


SELECT UserID, Username
FROM Users
WHERE Username = 'admin'
  AND PasswordHash = HASHBYTES('SHA2_256', '123456');

-- 3. Kiểm tra trạng thái active của user & nhân viên
SELECT U.Username, U.IsActive AS UserActive, E.IsActive AS EmpActive
FROM Users U
JOIN Employees E ON U.EmployeeID = E.EmployeeID
WHERE U.Username = 'admin'

UPDATE Users
SET PasswordHash       = HASHBYTES('SHA2_256', N'123456'),  -- chú ý có N phía trước
    MustChangePassword = 0
WHERE Username = 'admin';

INSERT INTO Suppliers (SupplierCode, SupplierName, Phone, Address, Email, IsActive)
VALUES
('NCC001', N'Công ty TNHH Phân Phối Điện Thoại MobilePro', '0901122334', N'Hà Nội', 'contact@mobilepro.vn', 1),
('NCC002', N'Công ty CP Thiết Bị Di Động Việt Techphone', '0912345678', N'Hồ Chí Minh', 'support@techphone.vn', 1),
('NCC003', N'Nhà phân phối Linh Kiện S-Mart Mobile', '0987766554', N'Đà Nẵng', 'info@smartmobile.vn', 1),
('NCC004', N'Cửa hàng Linh Kiện - Phụ Kiện Huy Hoàng Mobile', '0932123123', N'Hải Phòng', 'huyhoangmobile@gmail.com', 1),
('NCC005', N'Nhà cung cấp Thiết Bị Di Động FuturePhone', '0977889900', N'Cần Thơ', 'futurephone@gmail.com', 1);

SELECT SupplierID, SupplierCode, SupplierName
FROM Suppliers
ORDER BY SupplierID;

DBCC CHECKIDENT ('Suppliers', RESEED, 5);

DBCC CHECKIDENT ('Products', RESEED, 2);
SELECT ProductID, ProductCode, ProductName FROM Products;

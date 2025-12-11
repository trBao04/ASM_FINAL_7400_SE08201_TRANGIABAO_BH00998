
CREATE DATABASE StoreX;
GO

USE StoreX;
GO

-- 2. Bảng Roles (Nhóm quyền)

CREATE TABLE Roles (
    RoleID      INT IDENTITY(1,1) PRIMARY KEY,
    RoleName    NVARCHAR(50) NOT NULL UNIQUE,   -- 'Admin', 'Sales', 'Warehouse'
    Description NVARCHAR(255) NULL
);
GO

-- 3. Bảng Employees (Nhân viên)
CREATE TABLE Employees (
    EmployeeID   INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeCode VARCHAR(20) NOT NULL UNIQUE,
    FullName     NVARCHAR(100) NOT NULL,
    Position     NVARCHAR(50) NULL,
    Phone        VARCHAR(20) NULL,
    Address      NVARCHAR(255) NULL,
    Email        VARCHAR(100) NULL,
    RoleID       INT NOT NULL,
    IsActive     BIT NOT NULL DEFAULT 1,
    CreatedAt    DATETIME NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT FK_Employees_Roles
        FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
GO

-- 4. Bảng Users (Tài khoản đăng nhập)

CREATE TABLE Users (
    UserID             INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeID         INT NOT NULL UNIQUE,
    Username           VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash       VARBINARY(256) NOT NULL,
    PasswordSalt       VARBINARY(128) NULL,
    MustChangePassword BIT NOT NULL DEFAULT 1,
    IsActive           BIT NOT NULL DEFAULT 1,
    LastPasswordChange DATETIME NULL,
    LastLoginAt        DATETIME NULL,
    CreatedAt          DATETIME NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT FK_Users_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

-- 5. Bảng Customers (Khách hàng)

CREATE TABLE Customers (
    CustomerID   INT IDENTITY(1,1) PRIMARY KEY,
    CustomerCode VARCHAR(20) NOT NULL UNIQUE,
    FullName     NVARCHAR(100) NOT NULL,
    Phone        VARCHAR(20) NULL,
    Address      NVARCHAR(255) NULL,
    Email        VARCHAR(100) NULL,
    IsActive     BIT NOT NULL DEFAULT 1,
    CreatedAt    DATETIME NOT NULL DEFAULT(GETDATE())
);
GO

-- 6. Bảng Suppliers (Nhà cung cấp)

CREATE TABLE Suppliers (
    SupplierID   INT IDENTITY(1,1) PRIMARY KEY,
    SupplierCode VARCHAR(20) NOT NULL UNIQUE,
    SupplierName NVARCHAR(255) NOT NULL,
    Phone        VARCHAR(20) NULL,
    Address      NVARCHAR(255) NULL,
    Email        VARCHAR(100) NULL,
    IsActive     BIT NOT NULL DEFAULT 1,
    CreatedAt    DATETIME NOT NULL DEFAULT(GETDATE())
);
GO

ALTER TABLE PurchaseOrders
ADD CreatedAt DATETIME DEFAULT GETDATE();

-- 7. Bảng Categories (Loại sản phẩm)

CREATE TABLE Categories (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryCode VARCHAR(20) NOT NULL UNIQUE,
    CategoryName NVARCHAR(100) NOT NULL,
    Description  NVARCHAR(255) NULL
);
GO

-- 8. Bảng Products (Sản phẩm)
CREATE TABLE Products (
    ProductID       INT IDENTITY(1,1) PRIMARY KEY,
    ProductCode     VARCHAR(20) NOT NULL UNIQUE,
    ProductName     NVARCHAR(255) NOT NULL,
    CategoryID      INT NULL,
    Unit            NVARCHAR(20) NULL,             -- đơn vị (cái, hộp, ...)
    UnitPrice       DECIMAL(18,2) NOT NULL,        -- giá bán
    CostPrice       DECIMAL(18,2) NOT NULL,        -- giá vốn
    QuantityInStock INT NOT NULL DEFAULT 0,        -- tồn kho hiện tại
    ImagePath       NVARCHAR(255) NULL,            -- đường dẫn ảnh
    IsActive        BIT NOT NULL DEFAULT 1,
    CreatedAt       DATETIME NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT FK_Products_Categories
        FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

-- 9. Bảng PurchaseOrders (Phiếu nhập hàng)
CREATE TABLE PurchaseOrders (
    PurchaseOrderID INT IDENTITY(1,1) PRIMARY KEY,
    PONumber        VARCHAR(20) NOT NULL UNIQUE,
    SupplierID      INT NOT NULL,
    EmployeeID      INT NOT NULL,           -- nhân viên lập phiếu
    OrderDate       DATETIME NOT NULL DEFAULT(GETDATE()),
    TotalAmount     DECIMAL(18,2) NOT NULL DEFAULT 0,
    Status          TINYINT NOT NULL DEFAULT 1,  -- 1: Completed, 0: Draft, 2: Canceled...
    Notes           NVARCHAR(500) NULL,
    CONSTRAINT FK_PurchaseOrders_Suppliers
        FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    CONSTRAINT FK_PurchaseOrders_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

-- 10. Bảng PurchaseOrderDetails (Chi tiết phiếu nhập)
CREATE TABLE PurchaseOrderDetails (
    PurchaseOrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    PurchaseOrderID       INT NOT NULL,
    ProductID             INT NOT NULL,
    Quantity              INT NOT NULL CHECK (Quantity > 0),
    UnitCost              DECIMAL(18,2) NOT NULL CHECK (UnitCost >= 0),
    LineTotal AS (Quantity * UnitCost) PERSISTED,
    CONSTRAINT FK_PODetails_PurchaseOrders
        FOREIGN KEY (PurchaseOrderID) REFERENCES PurchaseOrders(PurchaseOrderID),
    CONSTRAINT FK_PODetails_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- 11. Bảng SalesInvoices (Hóa đơn bán hàng)
CREATE TABLE SalesInvoices (
    InvoiceID      INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceNumber  VARCHAR(20) NOT NULL UNIQUE,
    CustomerID     INT NULL,                     -- khách lẻ có thể NULL
    EmployeeID     INT NOT NULL,                 -- nhân viên bán hàng
    InvoiceDate    DATETIME NOT NULL DEFAULT(GETDATE()),
    TotalAmount    DECIMAL(18,2) NOT NULL DEFAULT 0,
    DiscountAmount DECIMAL(18,2) NOT NULL DEFAULT 0,
    TaxAmount      DECIMAL(18,2) NOT NULL DEFAULT 0,
    GrandTotal     AS (TotalAmount - DiscountAmount + TaxAmount) PERSISTED,
    Status         TINYINT NOT NULL DEFAULT 1,   -- 1: Completed, 0: Draft, 2: Canceled...
    Notes          NVARCHAR(500) NULL,
    CONSTRAINT FK_SalesInvoices_Customers
        FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    CONSTRAINT FK_SalesInvoices_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO


-- 12. Bảng SalesInvoiceDetails (Chi tiết hóa đơn)
--  - Có cột Profit để thống kê lợi nhuận theo sản phẩm/nhân viên
-------------------------------------------------
CREATE TABLE SalesInvoiceDetails (
    InvoiceDetailID  INT IDENTITY(1,1) PRIMARY KEY,
    InvoiceID        INT NOT NULL,
    ProductID        INT NOT NULL,
    Quantity         INT NOT NULL CHECK (Quantity > 0),
    UnitPrice        DECIMAL(18,2) NOT NULL CHECK (UnitPrice >= 0),
    DiscountPercent  DECIMAL(5,2) NOT NULL DEFAULT 0,       -- % chiết khấu dòng
    CostPriceAtSale  DECIMAL(18,2) NOT NULL CHECK (CostPriceAtSale >= 0),
    LineTotal        AS (Quantity * UnitPrice * (1 - DiscountPercent/100.0)) PERSISTED,
    Profit           AS ((UnitPrice - CostPriceAtSale) * Quantity) PERSISTED,
    CONSTRAINT FK_SalesInvoiceDetails_Invoices
        FOREIGN KEY (InvoiceID) REFERENCES SalesInvoices(InvoiceID),
    CONSTRAINT FK_SalesInvoiceDetails_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);
GO

-- 13. Bảng InventoryTransactions (Giao dịch kho)
CREATE TABLE InventoryTransactions (
    InventoryTransactionID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID              INT NOT NULL,
    TransactionType        CHAR(1) NOT NULL,        -- 'I' = Import, 'S' = Sale, 'A' = Adjust
    QuantityChange         INT NOT NULL,            -- nhập > 0, xuất < 0 (hoặc bạn quy ước)
    TransactionDate        DATETIME NOT NULL DEFAULT(GETDATE()),
    InvoiceDetailID        INT NULL,                -- nếu là xuất bán
    PurchaseOrderDetailID  INT NULL,                -- nếu là nhập hàng
    EmployeeID             INT NULL,
    Note                   NVARCHAR(255) NULL,
    CONSTRAINT CK_InventoryTransactions_Type
        CHECK (TransactionType IN ('I', 'S', 'A')),
    CONSTRAINT FK_InvTrans_Products
        FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    CONSTRAINT FK_InvTrans_InvoiceDetail
        FOREIGN KEY (InvoiceDetailID) REFERENCES SalesInvoiceDetails(InvoiceDetailID),
    CONSTRAINT FK_InvTrans_PODetail
        FOREIGN KEY (PurchaseOrderDetailID) REFERENCES PurchaseOrderDetails(PurchaseOrderDetailID),
    CONSTRAINT FK_InvTrans_Employees
        FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);
GO

-- 14. Một số index phục vụ tìm kiếm thường dùng

CREATE INDEX IX_Products_ProductName
ON Products(ProductName);

CREATE INDEX IX_Customers_FullName
ON Customers(FullName);

CREATE INDEX IX_SalesInvoices_InvoiceDate
ON SalesInvoices(InvoiceDate);

CREATE INDEX IX_PurchaseOrders_OrderDate
ON PurchaseOrders(OrderDate);
GO
select * from Categories
select * from Employees
-------------------------------------------------
-- 15. Dữ liệu mẫu cho Roles (nhóm quyền)
-------------------------------------------------
INSERT INTO Roles (RoleName, Description)
VALUES 
    (N'Admin',     N'Quản trị hệ thống, toàn quyền'),
    (N'Sales',     N'Nhân viên bán hàng'),
    (N'Warehouse', N'Nhân viên kho');
GO

INSERT INTO Categories (CategoryCode, CategoryName, Description)
VALUES
('DT', N'Điện thoại', N'Tất cả các loại điện thoại'),
('PK', N'Phụ kiện', N'Phụ kiện điện thoại'),
('TL', N'Máy tính bảng', N'Tablet các loại'),
('TN', N'Tai nghe', N'Tai nghe có dây / không dây'),
('SC', N'Sạc & Cáp', N'Sạc nhanh, cáp sạc, củ sạc'),
('OL', N'Ốp lưng', N'Bao da, ốp lưng điện thoại');


INSERT INTO Customers (CustomerCode, FullName, Phone, Address, Email)
VALUES ('C009', N'Pham Thi Hoa', '0938123456', N'Ha Noi', 'hoa@example.com');

UPDATE Employees
SET Phone = '0909999999'
WHERE EmployeeCode = 'NV002';

DELETE FROM Categories
WHERE CategoryID = 6;   

SELECT si.InvoiceID, si.InvoiceNumber, c.FullName, e.FullName AS EmployeeName, si.InvoiceDate
FROM SalesInvoices si
JOIN Customers c ON si.CustomerID = c.CustomerID
JOIN Employees e ON si.EmployeeID = e.EmployeeID;

SELECT 
    p.ProductName,
    p.QuantityInStock,
    s.SupplierName,
    po.OrderDate,
    pod.Quantity AS LastPurchasedQty
FROM Products p
LEFT JOIN PurchaseOrderDetails pod ON p.ProductID = pod.ProductID
LEFT JOIN PurchaseOrders po ON pod.PurchaseOrderID = po.PurchaseOrderID
LEFT JOIN Suppliers s ON po.SupplierID = s.SupplierID
WHERE p.QuantityInStock < 10
ORDER BY p.QuantityInStock ASC;




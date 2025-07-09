-- Tabla Roles
CREATE TABLE Roles (
    RoleId INT PRIMARY KEY IDENTITY,
    RoleName VARCHAR(50) UNIQUE NOT NULL
);

-- Tabla Users
CREATE TABLE Users (
    UserId INT PRIMARY KEY IDENTITY,
    Cedula VARCHAR(10) NOT NULL CHECK (LEN(Cedula) = 10 AND Cedula NOT LIKE '%[^0-9]%'),
    Email VARCHAR(100) UNIQUE NOT NULL,
    PasswordHash VARBINARY(64) NOT NULL,
    RoleId INT NOT NULL,
    RegistrationDate DATETIME DEFAULT GETDATE(),
    IsBlocked BIT DEFAULT 0,
    FailedLoginAttempts INT DEFAULT 0,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
);

CREATE TABLE Clients (
    ClientId INT PRIMARY KEY IDENTITY,
    UserId INT UNIQUE NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NULL,
    Phone VARCHAR(15) NULL,
    CONSTRAINT FK_Clients_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);
ALTER TABLE Clients
ADD Picture NVARCHAR(500);
-- Tabla Admins: datos específicos para administradores
CREATE TABLE Admins (
    AdminId INT PRIMARY KEY IDENTITY,
    UserId INT UNIQUE NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NULL,
    Phone VARCHAR(15) NULL,
    CONSTRAINT FK_Admins_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

-- Tabla Categories
CREATE TABLE Categories (
    CategoryId INT PRIMARY KEY IDENTITY,
    CategoryName VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Products (
    ProductId INT PRIMARY KEY IDENTITY,
    CategoryId INT NOT NULL,
    Name VARCHAR(150) NOT NULL,
    Description VARCHAR(250),
    Price DECIMAL(12,2) NOT NULL CHECK (Price >= 0),
    Stock INT NOT NULL CHECK (Stock >= 0),
    CONSTRAINT FK_Products_Categories FOREIGN KEY (CategoryId) REFERENCES Categories(CategoryId)
);

CREATE TABLE Orders (
    OrderId INT PRIMARY KEY IDENTITY,
    ClientId INT NOT NULL,
    OrderDate DATETIME DEFAULT GETDATE(),
    Total DECIMAL(12,2) NOT NULL,
    SubTotal DECIMAL(12,2) NOT NULL,
    Tax DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_Orders_Clients FOREIGN KEY (ClientId) REFERENCES Clients(ClientId)
);

-- Tabla OrderDetails (detalle de productos en cada orden)
CREATE TABLE OrderDetails (
    OrderDetailId INT PRIMARY KEY IDENTITY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_OrderDetails_Orders FOREIGN KEY (OrderId) REFERENCES Orders(OrderId),
    CONSTRAINT FK_OrderDetails_Products FOREIGN KEY (ProductId) REFERENCES Products(ProductId),
    CONSTRAINT UQ_Order_Product UNIQUE (OrderId, ProductId) -- no repetir producto en la misma orden
);

ALTER TABLE Products
ADD ImageUrl VARCHAR(255) NULL;
ALTER TABLE Products
ADD isActive int CHECK (isActive IN (0, 1));

CREATE TABLE Carts (
    CartId INT PRIMARY KEY IDENTITY,
    ClientId INT NOT NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    Total DECIMAL(12,2) NOT NULL DEFAULT 0,
    CONSTRAINT FK_Carts_Clients FOREIGN KEY (ClientId) REFERENCES Clients(ClientId)
);
CREATE TABLE CartItems (
    CartItemId INT PRIMARY KEY IDENTITY,
    CartId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitPrice DECIMAL(12,2) NOT NULL, 
    SubTotal DECIMAL(12,2) NOT NULL,
    CONSTRAINT FK_CartItems_Carts FOREIGN KEY (CartId) REFERENCES Carts(CartId),
    CONSTRAINT FK_CartItems_Products FOREIGN KEY (ProductId) REFERENCES Products(ProductId)
);

CREATE TABLE ErrorLogs (
    ErrorId INT IDENTITY PRIMARY KEY,
    Controller NVARCHAR(100),
    Method NVARCHAR(100),
    ErrorMessage NVARCHAR(MAX),
    StackTrace NVARCHAR(MAX),
    DateOccurred DATETIME DEFAULT GETDATE()
);

CREATE TABLE PasswordCed (
    PassId INT PRIMARY KEY IDENTITY,
    UserId INT NOT NULL,
    Cedula VARCHAR(10) NOT NULL,
    CONSTRAINT FK_PASS_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

CREATE FUNCTION dbo.CalcularDigitoVerificador
(
    @Cedula VARCHAR(10)
)
RETURNS INT
AS
BEGIN
    DECLARE @suma INT = 0
    DECLARE @i INT = 1
    DECLARE @digito INT
    DECLARE @coef INT

    WHILE @i <= 9
    BEGIN
        SET @digito = CAST(SUBSTRING(@Cedula, @i, 1) AS INT)
        IF @i % 2 = 1
        BEGIN
            SET @coef = @digito * 2
            IF @coef > 9 SET @coef = @coef - 9
        END
        ELSE
            SET @coef = @digito

        SET @suma = @suma + @coef
        SET @i = @i + 1
    END

    DECLARE @verificador INT = (10 - (@suma % 10)) % 10
    RETURN @verificador
END

CREATE or alter FUNCTION dbo.ValidarCedulaTungurahua

(
    @Cedula VARCHAR(10)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        CASE 
            WHEN LEN(@Cedula) <> 10 THEN 'La cédula debe tener 10 dígitos'
            WHEN ISNUMERIC(@Cedula) = 0 THEN 'La cédula debe contener solo números'
            WHEN LEFT(@Cedula, 2) <> '18' THEN 'La cédula no pertenece a Tungurahua'
            WHEN CAST(SUBSTRING(@Cedula, 3, 1) AS INT) >= 6 THEN 'El tercer dígito no puede ser mayor o igual a 6 para personas naturales'
            WHEN dbo.CalcularDigitoVerificador(@Cedula) <> CAST(RIGHT(@Cedula, 1) AS INT) THEN 'Cédula inválida'
            ELSE NULL
        END AS Error,
        CASE 
            WHEN LEN(@Cedula) = 10 
             AND ISNUMERIC(@Cedula) = 1
             AND LEFT(@Cedula, 2) = '18'
             AND CAST(SUBSTRING(@Cedula, 3, 1) AS INT) < 6
             AND dbo.CalcularDigitoVerificador(@Cedula) = CAST(RIGHT(@Cedula, 1) AS INT)
            THEN 'Cédula válida de Tungurahua'
            ELSE NULL
        END AS Message
)

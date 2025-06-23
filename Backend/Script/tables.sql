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

-- Tabla Clients: datos específicos para clientes
CREATE TABLE Clients (
    ClientId INT PRIMARY KEY IDENTITY,
    UserId INT UNIQUE NOT NULL,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Address VARCHAR(200) NULL,
    Phone VARCHAR(15) NULL,
    CONSTRAINT FK_Clients_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
);

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

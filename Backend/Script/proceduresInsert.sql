CREATE OR ALTER PROCEDURE CreateProduct
    @CategoryId INT,
    @Name VARCHAR(150),
    @Description VARCHAR(250),
    @Price DECIMAL(12,2),
    @Stock INT,
    @ImageUrl VARCHAR(255) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Products (CategoryId, Name, Description, Price, Stock, ImageUrl)
    VALUES (@CategoryId, @Name, @Description, @Price, @Stock, @ImageUrl);

    SELECT SCOPE_IDENTITY() AS ProductId;
END;
CREATE OR ALTER PROCEDURE CreateClient
    @Cedula VARCHAR(10),
    @Email VARCHAR(100),
    @Password VARCHAR(64),
    @FirstName VARCHAR(100),
    @LastName VARCHAR(100),
    @Address VARCHAR(200) = NULL,
    @Phone VARCHAR(15) = NULL
AS
BEGIN
        BEGIN TRY
        IF EXISTS (SELECT 1 FROM Users WHERE Cedula = @Cedula)
        BEGIN
            SELECT 'Ya existe un usuario con esa cédula.' AS ERROR
            RETURN;
        END

        IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
        BEGIN
            SELECT 'Ya existe un usuario con ese correo electrónico.' AS ERROR
            RETURN;
        END

        BEGIN TRANSACTION;

        INSERT INTO Users (Cedula, Email, PasswordHash, RoleId)
        VALUES (@Cedula, @Email, HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @Password)), 2);

        DECLARE @UserId INT = SCOPE_IDENTITY();

        INSERT INTO Clients (UserId, FirstName, LastName, Address, Phone)
        VALUES (@UserId, @FirstName, @LastName, @Address, @Phone);

        DECLARE @ClientId INT = SCOPE_IDENTITY();

        COMMIT TRANSACTION;

        SELECT @ClientId AS ClientId;
        END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            END CATCH
END;

CREATE OR ALTER PROCEDURE AddItemToCart
    @ClientId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @CartId INT, @UnitPrice DECIMAL(12,2), @ExistingQuantity INT = NULL, @NewQuantity INT;
    DECLARE @Stock INT;

    SELECT @CartId = CartId FROM Carts WHERE ClientId = @ClientId AND IsActive = 1;

    IF @CartId IS NULL
    BEGIN
        INSERT INTO Carts (ClientId) VALUES (@ClientId);
        SET @CartId = SCOPE_IDENTITY();
    END

    SELECT @UnitPrice = Price, @Stock = Stock FROM Products WHERE ProductId = @ProductId;

    IF @UnitPrice IS NULL
    BEGIN
        SELECT 'El producto no existe.' AS error;
        RETURN;
    END

    SELECT @ExistingQuantity = Quantity FROM CartItems WHERE CartId = @CartId AND ProductId = @ProductId;

    SET @NewQuantity = ISNULL(@ExistingQuantity, 0) + @Quantity;

    IF @NewQuantity > @Stock
    BEGIN
        SELECT 'No hay suficiente stock disponible.' AS error;
        RETURN;
    END

    IF @ExistingQuantity IS NOT NULL
    BEGIN
        UPDATE CartItems
        SET Quantity = @NewQuantity,
            SubTotal = @NewQuantity * @UnitPrice
        WHERE CartId = @CartId AND ProductId = @ProductId;
    END
    ELSE
    BEGIN
        INSERT INTO CartItems (CartId, ProductId, Quantity, UnitPrice, SubTotal)
        VALUES (@CartId, @ProductId, @Quantity, @UnitPrice, @Quantity * @UnitPrice);
    END

    UPDATE Carts
    SET Total = ISNULL((SELECT SUM(SubTotal) FROM CartItems WHERE CartId = @CartId), 0)
    WHERE CartId = @CartId;

    SELECT 'Producto agregado' AS Message;
END


CREATE OR ALTER PROCEDURE ConvertCartToOrder
    @CartId INT
AS BEGIN
    SET NOCOUNT ON;

    DECLARE @ClientId INT, @SubTotal DECIMAL(12,2), @Tax DECIMAL(12,2), @Total DECIMAL(12,2);
    DECLARE @OrderId INT;

    SELECT @ClientId = ClientId FROM Carts WHERE CartId = @CartId AND IsActive = 1;

    IF @ClientId IS NULL
    BEGIN
        SELECT 'El carrito no existe o ya fue procesado.' AS error;
        RETURN;
    END

    IF EXISTS (
        SELECT 1
        FROM CartItems ci
        JOIN Products p ON ci.ProductId = p.ProductId
        WHERE ci.CartId = @CartId AND ci.Quantity > p.Stock
    )
    BEGIN
        SELECT 
            p.ProductId,
            p.Name,
            p.Stock AS StockDisponible,
            ci.Quantity AS CantidadSolicitada,
            'El producto '+p.Name+' no tiene stock suficiente' AS error
        FROM CartItems ci
        JOIN Products p ON ci.ProductId = p.ProductId
        WHERE ci.CartId = @CartId AND  p.isActive = 0;
        
        RETURN;
    END

    BEGIN TRANSACTION;

    BEGIN TRY
        SELECT @SubTotal = SUM(SubTotal) FROM CartItems WHERE CartId = @CartId;
        SET @Tax = ROUND(@SubTotal * 0.12, 2);
        SET @Total = @SubTotal + @Tax;

        INSERT INTO Orders (ClientId, SubTotal, Tax, Total)
        VALUES (@ClientId, @SubTotal, @Tax, @Total);

        SET @OrderId = SCOPE_IDENTITY();

        INSERT INTO OrderDetails (OrderId, ProductId, Quantity, UnitPrice)
        SELECT @OrderId, ProductId, Quantity, UnitPrice
        FROM CartItems
        WHERE CartId = @CartId;

        UPDATE p
        SET Stock = Stock - ci.Quantity
        FROM Products p
        JOIN CartItems ci ON ci.ProductId = p.ProductId
        WHERE ci.CartId = @CartId;

        UPDATE Carts SET IsActive = 0 WHERE CartId = @CartId;

        COMMIT;

        SELECT 'Orden creada correctamente.' AS message, @OrderId AS OrderId;
    END TRY
    BEGIN CATCH
        ROLLBACK;

        SELECT ERROR_MESSAGE() AS error;
    END CATCH
END


CREATE OR ALTER PROCEDURE CreateOrder
    @ClientId INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Orders (ClientId, OrderDate, SubTotal, Tax, Total)
    VALUES (@ClientId, GETDATE(), 0, 0, 0);

    select SCOPE_IDENTITY() as OrderId,
    'Orden creada correctamente.' AS Message;
END

CREATE OR ALTER PROCEDURE AddOrUpdateOrderDetail
    @OrderId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UnitPrice DECIMAL(12,2), @Stock INT;
    DECLARE @ExistingQuantity INT = 0;
    DECLARE @SubTotal DECIMAL(12,2);

    SELECT @UnitPrice = Price, @Stock = Stock FROM Products WHERE ProductId = @ProductId;

    IF @UnitPrice IS NULL
    BEGIN
        SELECT 'El producto no existe.' AS error;
        RETURN;
    END

    SELECT @ExistingQuantity = Quantity FROM OrderDetails WHERE OrderId = @OrderId AND ProductId = @ProductId;

    IF @Quantity > @Stock
    BEGIN
        SELECT 'No hay suficiente stock disponible.' AS error;
        RETURN;
    END

    IF @ExistingQuantity = 0
    BEGIN
        -- Insertar nuevo detalle
        SET @SubTotal = @Quantity * @UnitPrice;

        INSERT INTO OrderDetails (OrderId, ProductId, Quantity, UnitPrice)
        VALUES (@OrderId, @ProductId, @Quantity, @UnitPrice);

        -- Reducir stock
        UPDATE Products SET Stock = Stock - @Quantity WHERE ProductId = @ProductId;
    END
    ELSE
    BEGIN
        -- Actualizar la cantidad sumando la nueva
        SET @SubTotal = (@ExistingQuantity + @Quantity) * @UnitPrice;

        UPDATE OrderDetails
        SET Quantity = @ExistingQuantity + @Quantity
        WHERE OrderId = @OrderId AND ProductId = @ProductId;

        -- Reducir solo la nueva cantidad del stock
        UPDATE Products SET Stock = Stock - @Quantity WHERE ProductId = @ProductId;
    END

    -- Actualizar totales en la orden
    DECLARE @TotalSub DECIMAL(12,2);
    SELECT @TotalSub = ISNULL(SUM(Quantity * UnitPrice), 0) FROM OrderDetails WHERE OrderId = @OrderId;

    DECLARE @Tax DECIMAL(12,2) = ROUND(@TotalSub * 0.12, 2);
    DECLARE @Total DECIMAL(12,2) = @TotalSub + @Tax;

    UPDATE Orders
    SET SubTotal = @TotalSub,
        Tax = @Tax,
        Total = @Total
    WHERE OrderId = @OrderId;

    SELECT 'Detalle agregado correctamente.' AS Message;
END


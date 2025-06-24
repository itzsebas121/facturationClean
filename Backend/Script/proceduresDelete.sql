CREATE OR ALTER PROCEDURE disableProduct
    @ProductId INT
AS
BEGIN
    UPDATE PRODUCTS
    SET ISACTIVE = 0
    where ProductId = @ProductId
END;

CREATE PROCEDURE enableProduct
    @ProductId INT
AS
BEGIN
    UPDATE PRODUCTS
    SET ISACTIVE = 1
    where ProductId = @ProductId
END;


CREATE OR ALTER PROCEDURE disableClient
    @ClientID INT
AS
BEGIN
    UPDATE U
    SET U.IsBlocked = 1
    FROM Users U
    JOIN Clients C ON C.UserId = U.UserId
    WHERE C.ClientId = @ClientId;

END;


CREATE OR ALTER PROCEDURE enableClient
    @ClientID INT
AS
BEGIN
    UPDATE U
    SET U.IsBlocked = 0, FailedLoginAttempts = 0
    FROM Users U
    JOIN Clients C ON C.UserId = U.UserId
    WHERE C.ClientId = @ClientId;

END;

CREATE OR ALTER PROCEDURE DeleteCartItem
    @CartId INT,
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (
            SELECT 1 FROM Carts
            WHERE CartId = @CartId AND IsActive = 1
        )
        BEGIN
            DELETE C
            FROM CartItems C
            JOIN Carts cs ON cs.CartId = C.CartId
            WHERE C.CartId = @CartId AND C.ProductId = @ProductId AND cs.IsActive = 1;

            IF @@ROWCOUNT = 0
            BEGIN
                SELECT 'El producto no existe en el carrito' AS Error;
                RETURN;
            END
            UPDATE Carts
            SET Total = (
                SELECT ISNULL(SUM(SubTotal), 0)
                FROM CartItems
                WHERE CartId = @CartId
            )
            WHERE CartId = @CartId;

            SELECT 'Producto eliminado correctamente' AS Message;
        END
        ELSE
        BEGIN
            SELECT 'El carrito no está activo o no existe' AS Error;
        END
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Error;
    END CATCH
END

CREATE OR ALTER PROCEDURE DeleteOrder
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM Orders WHERE OrderId = @OrderId)
    BEGIN
        DELETE FROM OrderDetails
        WHERE OrderId = @OrderId;
        DELETE FROM Orders
        WHERE OrderId = @OrderId;
    END
    ELSE
    BEGIN
        SELECT 'Orden no encontrada' AS Error;
    END
END;
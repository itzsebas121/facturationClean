CREATE PROCEDURE DeleteProduct
    @ProductId INT
AS
BEGIN
    DELETE FROM Products
    WHERE ProductId = @ProductId;
END;


CREATE OR ALTER PROCEDURE DeleteCartItem
    @CartId INT,
    @ProductId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM CartItems WHERE CartId = @CartId AND ProductId = @ProductId;

    UPDATE Carts
    SET Total = (
        SELECT ISNULL(SUM(SubTotal), 0) FROM CartItems WHERE CartId = @CartId
    )
    WHERE CartId = @CartId;
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
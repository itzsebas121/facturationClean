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

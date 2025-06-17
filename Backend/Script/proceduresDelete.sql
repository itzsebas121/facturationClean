CREATE PROCEDURE DeleteProduct
    @ProductId INT
AS
BEGIN
    DELETE FROM Products
    WHERE ProductId = @ProductId;
END;

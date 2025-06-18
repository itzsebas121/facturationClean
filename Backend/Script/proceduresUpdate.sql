CREATE PROCEDURE UpdateProduct
    @ProductId INT,
    @CategoryId INT,
    @Name VARCHAR(150),
    @Description VARCHAR(250),
    @Price DECIMAL(12,2),
    @Stock INT,
    @ImageUrl VARCHAR(255)
AS
BEGIN
    UPDATE Products
    SET 
        CategoryId = @CategoryId,
        Name = @Name,
        Description = @Description,
        Price = @Price,
        Stock = @Stock,
        ImageUrl = @ImageUrl
    WHERE ProductId = @ProductId;
END;



CREATE OR ALTER PROCEDURE UpdateCartItemQuantity
    @CartId INT,
    @ProductId INT,
    @Quantity INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UnitPrice DECIMAL(12,2), @Stock INT;

    SELECT @UnitPrice = UnitPrice FROM CartItems WHERE CartId = @CartId AND ProductId = @ProductId;
    SELECT @Stock = Stock FROM Products WHERE ProductId = @ProductId;

    IF @UnitPrice IS NULL
    BEGIN
        SELECT 'El producto no está en el carrito.' AS error;
        RETURN;
    END

    IF @Quantity > @Stock
    BEGIN
        SELECT 'La nueva cantidad supera el stock disponible.' AS error;
        RETURN;
    END

    UPDATE CartItems
    SET Quantity = @Quantity,
        SubTotal = @Quantity * @UnitPrice
    WHERE CartId = @CartId AND ProductId = @ProductId;

    UPDATE Carts
    SET Total = (SELECT SUM(SubTotal) FROM CartItems WHERE CartId = @CartId)
    WHERE CartId = @CartId;
END

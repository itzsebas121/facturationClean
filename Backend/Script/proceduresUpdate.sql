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

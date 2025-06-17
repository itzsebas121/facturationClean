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

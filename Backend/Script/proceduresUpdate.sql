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



CREATE OR ALTER PROCEDURE UpdateClient
    @ClientId INT,
    @Cedula VARCHAR(10),
    @Email VARCHAR(100),
    @FirstName VARCHAR(100),
    @LastName VARCHAR(100),
    @Address VARCHAR(200) = NULL,
    @Phone VARCHAR(15) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @UserId INT;
        SELECT @UserId = UserId FROM Clients WHERE ClientId = @ClientId;

        IF @UserId IS NULL
        BEGIN
            SELECT 'Cliente no encontrado' AS Error;
            RETURN;
        END

        UPDATE Users
        SET Cedula = @Cedula,
            Email = @Email
        WHERE UserId = @UserId;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 'No se pudo actualizar datos de usuario' AS Error;
            RETURN;
        END

        UPDATE Clients
        SET FirstName = @FirstName,
            LastName = @LastName,
            Address = @Address,
            Phone = @Phone
        WHERE ClientId = @ClientId;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 'No se pudo actualizar datos de cliente' AS Error;
            RETURN;
        END

        SELECT 'Cliente actualizado correctamente' AS Message;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Error;
    END CATCH
END
CREATE OR ALTER PROCEDURE UpdateClientPicture
    @ClientId INT,
    @ProfileImageUrl VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @UserId INT;
        SELECT @UserId = UserId FROM Clients WHERE ClientId = @ClientId;

        IF @UserId IS NULL
        BEGIN
            SELECT 'Cliente no encontrado' AS Error;
            RETURN;
        END

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 'No se pudo actualizar datos de usuario' AS Error;
            RETURN;
        END

        UPDATE Clients
        SET 
            Picture= @ProfileImageUrl
        WHERE ClientId = @ClientId;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT 'No se pudo actualizar datos de cliente' AS Error;
            RETURN;
        END

        SELECT 'Cliente actualizado correctamente' AS Message;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Error;
    END CATCH
END


CREATE OR ALTER PROCEDURE ChangePassword
    @UserId INT,
    @CurrentPassword VARCHAR(100),
    @NewPassword VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1 FROM Users 
            WHERE UserId = @UserId 
              AND PasswordHash = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @CurrentPassword))
        )
        BEGIN
            SELECT 'Contraseña actual incorrecta' AS Error;
            RETURN;
        END

        UPDATE Users
        SET PasswordHash = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @NewPassword))
        WHERE UserId = @UserId;

        SELECT 'Contraseña actualizada correctamente' AS Message;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Error;
    END CATCH
END

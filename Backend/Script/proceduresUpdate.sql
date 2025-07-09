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
        UPDATE Clients
        set Picture= @ProfileImageUrl
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
    @NewPassword VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        DECLARE @ValidacionCedula TABLE (Resultado VARCHAR(100));
        INSERT INTO @ValidacionCedula
        SELECT Resultado FROM dbo.ValidarCedulaTungurahua(@NewPassword);

        DECLARE @CedulaMensaje VARCHAR(100);
        SELECT @CedulaMensaje = Resultado FROM @ValidacionCedula;

        IF @CedulaMensaje <> 'Cédula válida de Tungurahua'
        BEGIN
            SELECT @CedulaMensaje AS Error;
            RETURN;
        END

        DECLARE @NewPasswordHash VARBINARY(MAX);
        SET @NewPasswordHash = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @NewPassword));

        IF EXISTS (
            SELECT 1
            FROM PasswordCed 
             WHERE UserId = @UserId 
              AND Cedula = @NewPassword
        )
        BEGIN
            SELECT 'Ya usaste esta contraseña anteriormente' AS Error;
            RETURN;
        END

        UPDATE Users
        SET PasswordHash = @NewPasswordHash
        WHERE UserId = @UserId;

        INSERT INTO PasswordCed (UserId, Cedula)
        VALUES (@UserId, CONVERT(VARCHAR(10), @NewPassword, 1));

        SELECT 'Contraseña actualizada correctamente' AS Message;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Error;
    END CATCH
END


select * from passwordced

exec ChangePassword
    @UserId =2,
    @NewPassword = '1850553593'


    
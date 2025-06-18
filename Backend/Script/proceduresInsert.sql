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


-----------------------------------------------------------------------------------
-- Procedimiento para registrar usuario con password hasheado
GO
CREATE OR ALTER PROCEDURE RegisterUser
    @Cedula VARCHAR(10),
    @Email VARCHAR(100),
    @Phone VARCHAR(15),
    @Password VARCHAR(255),
    @RoleName VARCHAR(50),
    @FirstName VARCHAR(100) = NULL,
    @LastName VARCHAR(100) = NULL,
    @Address VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar rol
    DECLARE @RoleId INT;
    SELECT @RoleId = RoleId FROM Roles WHERE RoleName = @RoleName;
    IF @RoleId IS NULL
    BEGIN
        RAISERROR('Role does not exist.', 16, 1);
        RETURN;
    END

    -- Verificar email o cedula duplicados
    IF EXISTS (SELECT 1 FROM Users WHERE  Cedula = @Cedula)
    BEGIN
        RAISERROR('Cedula already registered.', 16, 1);
        RETURN;
    END
    IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
    BEGIN
        RAISERROR('Email  already registered.', 16, 1);
        RETURN;
    END

    -- Insertar usuario
    INSERT INTO Users (Cedula, Email, Phone, PasswordHash, RoleId)
    VALUES (
        @Cedula,
        @Email,
        @Phone,
        HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @Password)),
        @RoleId
    );

    DECLARE @UserId INT = SCOPE_IDENTITY();

    -- Si es cliente, insertar datos en Clients
    IF @RoleName = 'Client'
    BEGIN
        INSERT INTO Clients (UserId, FirstName, LastName, Address)
        VALUES (@UserId, @FirstName, @LastName, @Address);
    END
END;
GO

-----------------------------------------------------------------------------------
-- Procedimiento para validar login
CREATE OR ALTER PROCEDURE ValidateUserLogin
    @Email VARCHAR(100),
    @Password VARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @UserId INT;
    DECLARE @StoredPassword VARBINARY(64);
    DECLARE @RoleId INT;
    DECLARE @IsBlocked BIT;
    DECLARE @FailedAttempts INT;

    SELECT 
        @UserId = UserId,
        @StoredPassword = PasswordHash,
        @RoleId = RoleId,
        @IsBlocked = IsBlocked,
        @FailedAttempts = FailedLoginAttempts
    FROM Users WHERE Email = @Email;

    IF @UserId IS NULL
    BEGIN
        SELECT 'Invalid credentials' AS Message;
        RETURN;
    END

    IF @IsBlocked = 1
    BEGIN
        SELECT 'User blocked due to multiple failed login attempts' AS Message;
        RETURN;
    END

    IF @StoredPassword = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @Password))
    BEGIN
        -- Login correcto: resetear contador de intentos fallidos
        UPDATE Users SET FailedLoginAttempts = 0 WHERE UserId = @UserId;

        SELECT 
            u.UserId,
            u.Email,
            r.RoleName,
            'Login successful' AS Message
        FROM Users u
        JOIN Roles r ON u.RoleId = r.RoleId
        WHERE u.UserId = @UserId;
    END
    ELSE
    BEGIN
        -- Login fallido: incrementar contador
        UPDATE Users SET FailedLoginAttempts = FailedLoginAttempts + 1 WHERE UserId = @UserId;

        -- Bloquear usuario si supera 3 intentos
        UPDATE Users
        SET IsBlocked = CASE WHEN FailedLoginAttempts >= 3 THEN 1 ELSE 0 END
        WHERE UserId = @UserId;

        SELECT 'Invalid credentials' AS Message;
    END
END;

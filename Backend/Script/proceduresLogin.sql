-----------------------------------------------------------------------------------
-- Procedimiento para registrar usuario con password hasheado
CREATE OR ALTER PROCEDURE RegisterUser
    @Cedula VARCHAR(10),
    @Email VARCHAR(100),
    @Password VARCHAR(255),
    @RoleName VARCHAR(50),
    @FirstName VARCHAR(100),
    @LastName VARCHAR(100),
    @Address VARCHAR(200) = NULL,
    @Phone VARCHAR(15) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Validar rol y obtener RoleId
    DECLARE @RoleId INT;
    SELECT @RoleId = RoleId FROM Roles WHERE RoleName = @RoleName;

    IF @RoleId IS NULL
    BEGIN
        RAISERROR('Role does not exist.', 16, 1);
        RETURN;
    END

    -- Validar que no exista cedula ni email duplicados
    IF EXISTS (SELECT 1 FROM Users WHERE Cedula = @Cedula)
    BEGIN
        RAISERROR('Cedula already registered.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Users WHERE Email = @Email)
    BEGIN
        RAISERROR('Email already registered.', 16, 1);
        RETURN;
    END

    -- Insertar en Users
    INSERT INTO Users (Cedula, Email, PasswordHash, RoleId)
    VALUES (
        @Cedula,
        @Email,
        HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @Password)),
        @RoleId
    );

    DECLARE @UserId INT = SCOPE_IDENTITY();

    -- Insertar en tabla específica según rol
    IF @RoleName = 'Client'
    BEGIN
        INSERT INTO Clients (UserId, FirstName, LastName, Address, Phone)
        VALUES (@UserId, @FirstName, @LastName, @Address, @Phone);
    END
    ELSE IF @RoleName = 'Admin'
    BEGIN
        INSERT INTO Admins (UserId, FirstName, LastName, Address, Phone)
        VALUES (@UserId, @FirstName, @LastName, @Address, @Phone);
    END
    ELSE
    BEGIN
        -- Si hay otros roles, manejar o dejar pasar
        -- Por ahora, si el rol no es Admin o Client, no se insertan datos específicos
        PRINT 'No additional user data to insert for this role.';
    END
END;


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

    -- Obtener datos comunes de Users
    SELECT 
        @UserId = UserId,
        @StoredPassword = PasswordHash,
        @RoleId = RoleId,
        @IsBlocked = IsBlocked,
        @FailedAttempts = FailedLoginAttempts
    FROM Users 
    WHERE Email = @Email;

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
        -- Login correcto: resetear contador
        UPDATE Users SET FailedLoginAttempts = 0 WHERE UserId = @UserId;

        -- Dependiendo del rol, obtener info extendida
        IF @RoleId = (SELECT RoleId FROM Roles WHERE RoleName = 'Admin')
        BEGIN
            SELECT 
                u.UserId,
                u.Email,
                r.RoleName AS Role,
                a.FirstName + ' '+ a.LastName as Name,
                a.Address,
                a.Phone,
                'Login successful' AS Message
            FROM Users u
            JOIN Roles r ON u.RoleId = r.RoleId
            JOIN Admins a ON a.UserId = u.UserId
            WHERE u.UserId = @UserId;
        END
        ELSE IF @RoleId = (SELECT RoleId FROM Roles WHERE RoleName = 'Client')
        BEGIN
            SELECT 
                u.UserId,
                u.Email,
                r.RoleName AS Role,
                c.FirstName + ' '+ c.LastName as Name,
                c.Address,
                c.Phone,
                c.ClientId,
                'Login successful' AS Message
            FROM Users u
            JOIN Roles r ON u.RoleId = r.RoleId
            JOIN Clients c ON c.UserId = u.UserId
            WHERE u.UserId = @UserId;
        END
        ELSE
        BEGIN
            SELECT 'Rol no reconocido' AS Message;
        END
    END
    ELSE
    BEGIN
        -- Login fallido: aumentar contador e intentar bloqueo
        UPDATE Users SET FailedLoginAttempts = FailedLoginAttempts + 1 WHERE UserId = @UserId;

        UPDATE Users
        SET IsBlocked = CASE WHEN FailedLoginAttempts >= 3 THEN 1 ELSE 0 END
        WHERE UserId = @UserId;

        SELECT 'Invalid credentials' AS Message;
    END
END;

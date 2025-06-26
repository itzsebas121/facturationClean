CREATE OR ALTER PROCEDURE getProducts
    @FiltroGeneral NVARCHAR(200) = NULL,
    @CategoryId INT = NULL,
    @Page INT = 1,
    @PageSize INT = 10,
    @EsAdmin BIT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Page - 1) * @PageSize;

    SELECT 
        p.ProductId,
        p.CategoryId,
        c.CategoryName,
        p.Name,
        p.Description,
        p.Price,
        p.Stock,
        p.isActive,
        p.ImageUrl
    INTO #ProductosFiltrados
    FROM Products p
    INNER JOIN Categories c ON p.CategoryId = c.CategoryId
    WHERE (
        @FiltroGeneral IS NULL OR
        p.Name LIKE '%' + @FiltroGeneral + '%' OR
        p.Description LIKE '%' + @FiltroGeneral + '%' OR
        c.CategoryName LIKE '%' + @FiltroGeneral + '%' OR
        CAST(p.Price AS NVARCHAR) LIKE '%' + @FiltroGeneral + '%' OR
        CAST(p.Stock AS NVARCHAR) LIKE '%' + @FiltroGeneral + '%'
    )
    AND (@CategoryId IS NULL OR p.CategoryId = @CategoryId)
    AND (
        ISNULL(@EsAdmin, 0) = 1 OR 
        (p.Stock > 0 AND p.isActive = 1)
    );

    SELECT *
    FROM #ProductosFiltrados
    ORDER BY ProductId
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*) AS Total
    FROM #ProductosFiltrados;

    DROP TABLE #ProductosFiltrados;
END;

CREATE OR ALTER PROCEDURE getClients
AS
BEGIN
    SELECT 
        c.ClientId,
        c.FirstName+' '+c.LastName as Name,
        c.FirstName,
        c.LastName,
        c.Address,
        c.Phone,
        u.Cedula,
        c.Picture,
        u.UserId,
        u.Email,
        u.IsBlocked
    FROM Clients c
    Join Users u on u.UserId = c.UserId
END;
go
CREATE OR ALTER PROCEDURE getClientById
    @ClientId int
AS
BEGIN
    SELECT 
        c.ClientId,
        c.FirstName,
        c.LastName,
        c.Address,
        c.Phone,
        u.Cedula,
        u.UserId,
        c.Picture,
        u.Email
    FROM Clients c
    Join Users u on u.UserId = c.UserId
    where c.ClientId= @ClientId 
END

CREATE PROCEDURE getCategories
AS
BEGIN
    SELECT 
        CategoryId,
        CategoryName
    FROM Categories
END;


CREATE OR ALTER PROCEDURE getOrders
    @ClientId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        o.OrderId,
        u.Cedula,
        c.FirstName + ' ' + c.LastName AS Name,
        c.ClientId,
        c.Address,
        c.Phone,
        u.Email,
        o.OrderDate,
        o.SubTotal,
        o.Tax,
        o.Total
    FROM Orders o
    JOIN Clients c ON c.ClientId = o.ClientId
    JOIN Users u ON u.UserId = c.UserId
    WHERE (@ClientId IS NULL OR c.ClientId = @ClientId)
    ORDER BY o.OrderDate DESC;
END;


CREATE OR ALTER PROCEDURE getCartClient
    @ClientID int
AS
BEGIN
    SELECT
        p.Name,
        p.ImageUrl,
        c.* 
    FROM CartItems c
    JOIN Products p on p.ProductId = c.ProductId
    JOIN Carts cs on cs.CartId = c.CartId
    JOIN Clients cl on cl.ClientId = cs.ClientId
    where cl.ClientId = @ClientID
    AND CS.IsActive = 1
END;
CREATE OR ALTER PROCEDURE getOrderById
    @OrderId int
AS
BEGIN
    Select 
    p.Name,
    p.ImageUrl,
    p.Price,
    (p.Price * od.Quantity) as SubTotal,
    od.* 
    from orderdetails od
    JOIN Products p on p.ProductId = od.ProductId
    where od.OrderId = @OrderId
END;

CREATE OR ALTER PROCEDURE RecoverPassword
    @Email VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        DECLARE @UserId INT;
        SELECT @UserId = UserId FROM Users WHERE Email = @Email;

        IF @UserId IS NULL
        BEGIN
            SELECT 'El correo no está registrado' AS Error;
            RETURN;
        END

        DECLARE @TempPassword VARCHAR(20) = LEFT(NEWID(), 8);

        UPDATE Users
        SET PasswordHash = HASHBYTES('SHA2_256', CONVERT(VARBINARY(MAX), @TempPassword))
        WHERE UserId = @UserId;

        SELECT 'Contraseña restablecida correctamente' AS Message, @TempPassword AS TemporaryPassword;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS Error;
    END CATCH
END

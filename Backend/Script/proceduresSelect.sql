CREATE OR ALTER PROCEDURE getProducts
    @FiltroGeneral NVARCHAR(200) = NULL,
    @CategoryId INT = NULL,
    @Page INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Page - 1) * @PageSize;

    -- Tabla temporal para almacenar el filtrado
    SELECT 
        p.ProductId,
        p.CategoryId,
        c.CategoryName,
        p.Name,
        p.Description,
        p.Price,
        p.Stock,
        p.ImageUrl
    INTO #ProductosFiltrados
    FROM Products p
    INNER JOIN Categories c ON p.CategoryId = c.CategoryId
    WHERE (
        (@FiltroGeneral IS NULL OR
         p.Name LIKE '%' + @FiltroGeneral + '%' OR
         p.Description LIKE '%' + @FiltroGeneral + '%' OR
         c.CategoryName LIKE '%' + @FiltroGeneral + '%' OR
         CAST(p.Price AS NVARCHAR) LIKE '%' + @FiltroGeneral + '%' OR
         CAST(p.Stock AS NVARCHAR) LIKE '%' + @FiltroGeneral + '%')
    )
    AND (@CategoryId IS NULL OR p.CategoryId = @CategoryId);

    -- Resultado paginado
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
        c.Address,
        c.Phone,
        u.Cedula,
        u.Email,
        u.IsBlocked
    FROM Clients c
    Join Users u on u.UserId = c.UserId
END;
CREATE PROCEDURE getCategories
AS
BEGIN
    SELECT 
        CategoryId,
        CategoryName
    FROM Categories
END;



CREATE PROCEDURE getProducts
    @FiltroGeneral NVARCHAR(200) = NULL,
    @Page INT = 1,
    @PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@Page - 1) * @PageSize;

    SELECT 
        p.ProductId,
        c.CategoryName,
        p.Name,
        p.Description,
        p.Price,
        p.Stock,
        p.ImageUrl
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
    ORDER BY p.ProductId
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END;

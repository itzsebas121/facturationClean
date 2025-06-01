DECLARE @Adjetivos TABLE (Word VARCHAR(50));
INSERT INTO @Adjetivos VALUES
('Nuevo'), ('Moderno'), ('Premium'), ('Económico'), ('Compacto'),
('Ligero'), ('Duradero'), ('Portátil'), ('Clásico'), ('Avanzado');

DECLARE @Nombres TABLE (Word VARCHAR(50));
INSERT INTO @Nombres VALUES
('Teléfono'), ('Camiseta'), ('Zapato'), ('Laptop'), ('Refrigerador'),
('Cafetera'), ('Pantalón'), ('Silla'), ('Tablet'), ('Auriculares'),
('Camisa'), ('Smartwatch'), ('Pan'), ('Juguete'), ('Lámpara'),
('Reloj'), ('Bolso'), ('Televisor'), ('Cámara'), ('Monitor');

DECLARE @i INT = 1;

WHILE @i <= 10000
BEGIN
    DECLARE @CategoryId INT = (SELECT TOP 1 CategoryId FROM Categories ORDER BY NEWID());
    DECLARE @Adj VARCHAR(50) = (SELECT TOP 1 Word FROM @Adjetivos ORDER BY NEWID());
    DECLARE @Nom VARCHAR(50) = (SELECT TOP 1 Word FROM @Nombres ORDER BY NEWID());
    DECLARE @Name VARCHAR(150) = @Adj + ' ' + @Nom;
    DECLARE @Description VARCHAR(250) = 'Este es un producto ' + @Adj + ' de tipo ' + @Nom + '.';
    DECLARE @Price DECIMAL(12,2) = ROUND((RAND(CHECKSUM(NEWID())) * 1000) + 1, 2);
    DECLARE @Stock INT = CAST((RAND(CHECKSUM(NEWID())) * 100) AS INT);

    -- Picsum fotos aleatorias, tamaño fijo 150x150, usando @i para variar imagen
    DECLARE @ImageUrl VARCHAR(255) = 'https://picsum.photos/seed/' + CAST(@i AS VARCHAR) + '/150/150';

    INSERT INTO Products (CategoryId, Name, Description, Price, Stock, ImageUrl)
    VALUES (@CategoryId, @Name, @Description, @Price, @Stock, @ImageUrl);

    SET @i = @i + 1;
END

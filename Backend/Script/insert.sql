-- Insertar Roles base
INSERT INTO Roles (RoleName) VALUES ('Admin'), ('Client');

-- Insertar Categorías base
INSERT INTO Categories (CategoryName) VALUES ('Electrónica'), ('Ropa'), ('Alimentos'), ('Hogar');

-- Ejemplo: insertar un usuario cliente con su info completa (usa el procedimiento RegisterUser)
EXEC RegisterUser
    @Cedula = '0123456789',
    @Email = 'cliente@ejemplo.com',
    @Phone = '5551234567',
    @Password = 'PassSeguro123',
    @RoleName = 'Client',
    @FirstName = 'Sebas',
    @LastName = 'Perez',
    @Address = 'Calle Falsa 123';

-- Ejemplo: insertar un usuario administrador
EXEC RegisterUser
    @Cedula = '9876543210',
    @Email = 'admin@ejemplo.com',
    @Phone = '5559876543',
    @Password = 'AdminPass456',
    @RoleName = 'Admin';

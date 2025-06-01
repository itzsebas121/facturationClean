-- Insertar Roles base
INSERT INTO Roles (RoleName) VALUES ('Admin'), ('Client');

-- Insertar Categorías base
INSERT INTO Categories (CategoryName) VALUES ('Electrónica'), ('Ropa'), ('Alimentos'), ('Hogar');

-- Insertar un usuario cliente con su info completa
EXEC RegisterUser
    @Cedula = '0123456789',
    @Email = 'cliente@ejemplo.com',
    @Password = 'PassSeguro123',
    @RoleName = 'Client',
    @FirstName = 'Sebas',
    @LastName = 'Perez',
    @Address = 'Calle Falsa 123',
    @Phone = '5551234567';

-- Insertar un usuario administrador
EXEC RegisterUser
    @Cedula = '9876543210',
    @Email = 'admin@ejemplo.com',
    @Password = 'AdminPass456',
    @RoleName = 'Admin',
    @FirstName = 'Admin',
    @LastName = 'Ejemplo',
    @Address = NULL,
    @Phone = '5559876543';
    

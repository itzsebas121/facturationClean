# Implementación de Endpoints de Cliente

## Funcionalidades Implementadas

Se han implementado exitosamente los endpoints para:

1. **Actualizar información del cliente** (PUT `/api/clients`)
2. **Cambiar contraseña del cliente** (PUT `/api/clients/changePassword`)

## Estructura de la Implementación

### 1. Servicios (Backend Integration)

#### `lib/services/client_service.dart`
- **`updateClient(Client client)`**: Actualiza la información del cliente
  - Método: PUT
  - Endpoint: `/api/clients`
  - Body: JSON con datos del cliente
  - Respuesta: Mensaje de confirmación o error

- **`changePassword({currentPassword, newPassword})`**: Cambia la contraseña del cliente
  - Método: PUT
  - Endpoint: `/api/clients/changePassword`
  - Body: JSON con userId, contraseña actual y nueva
  - Respuesta: Mensaje de confirmación o error

### 2. Modelos

#### `lib/models/client.dart`
- Estructura de datos del cliente
- Métodos `fromJson()`, `toJson()`, y `copyWith()`
- Campos: clientId, cedula, email, firstName, lastName, address, phone

### 3. Pantallas de Usuario

#### `lib/screens/profile_screen.dart`
- Pantalla principal del perfil del usuario
- Muestra información personal
- Navegación a edición de perfil y cambio de contraseña
- Función de logout

#### `lib/screens/edit_profile_screen.dart`
- Formulario para editar información personal
- Validación de campos
- Integración con `ClientService.updateClient()`
- Manejo de errores y confirmaciones

#### `lib/screens/change_password_screen.dart`
- Formulario para cambiar contraseña
- Validación de seguridad de contraseñas
- Integración con `ClientService.changePassword()`
- Confirmación de contraseña

## Navegación

### Acceso al Perfil
El botón de perfil está disponible en la barra superior de la pantalla principal de productos:
- Icono: 👤 (person)
- Ubicación: AppBar de `ProductListScreen`
- Tooltip: "Mi perfil"

### Flujo de Navegación
```
ProductListScreen
    └── ProfileScreen
        ├── EditProfileScreen
        └── ChangePasswordScreen
```

## Uso de las Funcionalidades

### 1. Ver Perfil
1. Iniciar sesión en la aplicación
2. Desde la pantalla de productos, tocar el icono de perfil (👤) en la barra superior
3. Ver información personal completa

### 2. Editar Perfil
1. En la pantalla de perfil, tocar "Editar Perfil"
2. Modificar los campos deseados
3. Tocar "Guardar Cambios"
4. Confirmar o corregir errores según sea necesario

### 3. Cambiar Contraseña
1. En la pantalla de perfil, tocar "Cambiar Contraseña"
2. Ingresar contraseña actual
3. Ingresar nueva contraseña (mínimo 8 caracteres)
4. Confirmar nueva contraseña
5. Tocar "Cambiar Contraseña"

## Validaciones Implementadas

### Edición de Perfil
- **Cédula**: Mínimo 8 caracteres, obligatorio
- **Nombre**: Mínimo 2 caracteres, obligatorio
- **Apellido**: Mínimo 2 caracteres, obligatorio
- **Email**: Formato válido, obligatorio
- **Teléfono**: Mínimo 7 dígitos, obligatorio
- **Dirección**: Mínimo 5 caracteres, obligatorio

### Cambio de Contraseña
- **Contraseña actual**: Obligatoria
- **Nueva contraseña**: 
  - Mínimo 8 caracteres
  - Debe ser diferente a la actual
  - Obligatoria
- **Confirmación**: Debe coincidir con la nueva contraseña

## Manejo de Errores

### Errores del Servidor
- **400 Bad Request**: Datos inválidos
- **401 Unauthorized**: Contraseña actual incorrecta
- **404 Not Found**: Cliente/Usuario no encontrado
- **500 Server Error**: Error interno del servidor

### Errores de Cliente
- Validación de formularios en tiempo real
- Mensajes de error específicos por campo
- Confirmaciones de éxito con SnackBar/Dialog

## Temas y Estilos

Todas las pantallas utilizan el tema personalizado definido en `lib/theme/app_theme.dart`:
- Colores consistentes con el diseño de la aplicación
- Modo claro/oscuro según configuración del sistema
- Componentes Material Design 3

## Integración con Backend

### Headers HTTP
```dart
{
  'Content-Type': 'application/json'
}
```

### Body para Actualizar Cliente
```json
{
  "clientId": 12,
  "cedula": "1234567890",
  "email": "cliente@email.com", 
  "firstName": "Juan",
  "lastName": "Pérez",
  "address": "Av. Siempre Viva 742",
  "phone": "0987654321"
}
```

### Body para Cambiar Contraseña
```json
{
  "userId": 42,
  "currentPassword": "MiClaveActual123",
  "newPassword": "NuevaClaveSegura456"
}
```

## Estado de la Implementación

### ✅ Completado
- [x] Servicios de backend (ClientService)
- [x] Modelos de datos (Client)
- [x] Pantalla de perfil (ProfileScreen)
- [x] Pantalla de edición (EditProfileScreen)
- [x] Pantalla de cambio de contraseña (ChangePasswordScreen)
- [x] Navegación integrada
- [x] Validaciones de formularios
- [x] Manejo de errores
- [x] Temas aplicados
- [x] Compilación exitosa

### 🔄 Pendiente de Pruebas
- [ ] Pruebas de integración con backend real
- [ ] Validación de endpoints en servidor
- [ ] Pruebas de usuario final

## Archivos Modificados/Creados

### Nuevos Archivos
- `lib/screens/profile_screen.dart`
- `lib/screens/edit_profile_screen.dart`
- `lib/screens/change_password_screen.dart`
- `lib/models/client.dart`

### Archivos Modificados
- `lib/services/client_service.dart` (extendido)
- `lib/screens/product_list_screen.dart` (botón de perfil)

La implementación está completa y lista para ser probada con el backend.

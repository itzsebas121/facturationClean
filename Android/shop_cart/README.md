# 🛒 Shop Cart - Sistema de Facturación Móvil

Sistema de facturación móvil desarrollado en Flutter con autenticación JWT, gestión de productos, clientes y generación de recibos con impresión nativa.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Requisitos del Sistema](#-requisitos-del-sistema)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
- [Uso de la Aplicación](#-uso-de-la-aplicación)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [API Endpoints](#-api-endpoints)
- [Dependencias Principales](#-dependencias-principales)
- [Características Técnicas](#-características-técnicas)
- [Desarrollo y Contribución](#-desarrollo-y-contribución)
- [Solución de Problemas](#-solución-de-problemas)
- [Licencia](#-licencia)

## ✨ Características

### 🔐 Autenticación y Seguridad
- Login con JWT (JSON Web Tokens)
- Persistencia de sesión automática
- Logout seguro con limpieza de datos
- Manejo de expiración de sesiones

### 👥 Gestión de Clientes
- Búsqueda de clientes por cédula/RUC
- Validación de datos de identificación
- Campos no editables para información del cliente
- Feedback visual para estados de carga

### 🛍️ Gestión de Productos
- Búsqueda de productos por código/nombre
- Paginación con navegación intuitiva
- Filtros avanzados por categoría
- Gestión de inventario en tiempo real

### 🧾 Facturación
- Generación de recibos/facturas
- Impresión nativa usando el servicio del sistema
- Vista previa antes de imprimir
- Exportación a PDF
- Cálculo automático de totales e impuestos

### 🎨 Interfaz de Usuario
- Diseño Material Design
- Animaciones fluidas
- Estados de carga con indicadores
- Feedback háptico
- Responsive design para diferentes tamaños de pantalla

## 🔧 Requisitos del Sistema

### Software Requerido
- **Flutter SDK**: >= 3.7.2
- **Dart SDK**: >= 3.0.0
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Git** para control de versiones

### Plataformas Soportadas
- ✅ Android (API 21+)
- ✅ iOS (11.0+)
- ✅ Web
- ✅ Windows
- ✅ macOS
- ✅ Linux

## 📦 Instalación

### 1. Clonar el Repositorio
```bash
git clone https://github.com/tu-usuario/shop_cart.git
cd shop_cart
```

### 2. Instalar Dependencias
```bash
flutter pub get
```

### 3. Verificar Instalación
```bash
flutter doctor
```

### 4. Ejecutar la Aplicación
```bash
# Para desarrollo
flutter run

# Para Android
flutter run -d android

# Para iOS
flutter run -d ios

# Para Web
flutter run -d web
```

## ⚙️ Configuración

### Variables de Entorno
Configura las siguientes variables en el archivo `lib/services/` según tu backend:

```dart
// En user_service.dart
static const String _baseUrl = 'https://tu-api.com';

// En product_service.dart  
static const String _baseUrl = 'https://tu-api.com';

// En client_service.dart
static const String _baseUrl = 'https://tu-api.com';
```

### Configuración de Red
Para desarrollo local, asegúrate de permitir conexiones HTTP no seguras:

#### Android
En `android/app/src/main/AndroidManifest.xml`:
```xml
<application
    android:usesCleartextTraffic="true"
    ...>
```

#### iOS
En `ios/Runner/Info.plist`:
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## 🚀 Uso de la Aplicación

### 1. Inicio de Sesión
- Ingresa tus credenciales
- La app recordará tu sesión automáticamente
- Usa el botón "Cerrar Sesión" para salir de forma segura

### 2. Gestión de Productos
- Busca productos por código o nombre
- Usa la paginación para navegar por los resultados
- Aplica filtros para encontrar productos específicos
- Agrega productos al carrito con cantidad personalizada

### 3. Selección de Cliente
- Busca clientes por cédula o RUC
- Los datos del cliente se cargan automáticamente
- Los campos se bloquean para evitar modificaciones accidentales

### 4. Facturación
- Revisa los productos en el carrito
- Verifica los totales calculados
- Genera el recibo
- Imprime usando el servicio nativo del sistema

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── models/                      # Modelos de datos
│   ├── product.dart
│   ├── client.dart
│   └── cart_item.dart
├── screens/                     # Pantallas principales
│   ├── login_screen.dart
│   ├── product_list_screen_new.dart
│   └── order_detail_screen_new.dart
├── services/                    # Servicios de API y lógica de negocio
│   ├── user_service.dart
│   ├── product_service.dart
│   ├── client_service.dart
│   └── cart_service.dart
├── widgets/                     # Widgets reutilizables
│   ├── pagination_widget.dart
│   ├── search_filters.dart
│   └── receipt_print_button.dart
└── utils/                       # Utilidades y helpers
    └── validators.dart
```

## 🌐 API Endpoints

### Autenticación
- `POST /api/auth/login` - Inicio de sesión
- `POST /api/auth/refresh` - Renovar token
- `POST /api/auth/logout` - Cerrar sesión

### Productos
- `GET /api/products` - Listar productos (con paginación)
- `GET /api/products/search` - Buscar productos
- `GET /api/products/categories` - Obtener categorías

### Clientes
- `GET /api/clients/search` - Buscar cliente por cédula/RUC
- `GET /api/clients/{id}` - Obtener datos del cliente

### Facturación
- `POST /api/orders` - Crear nueva orden
- `GET /api/orders/{id}` - Obtener detalles de orden

## 📚 Dependencias Principales

### Core
- `flutter`: Framework de desarrollo
- `http`: Cliente HTTP para API calls
- `shared_preferences`: Persistencia de datos local
- `jwt_decoder`: Decodificación de tokens JWT

### UI/UX
- `cupertino_icons`: Iconos de iOS
- `intl`: Internacionalización y formateo
- `image_picker`: Selector de imágenes

### Funcionalidades Específicas
- `pdf`: Generación de documentos PDF
- `printing`: Impresión nativa
- `share_plus`: Compartir contenido
- `path_provider`: Acceso a directorios del sistema

### Desarrollo
- `flutter_lints`: Reglas de código recomendadas
- `flutter_test`: Framework de testing

## 🛠️ Características Técnicas

### Arquitectura
- **Patrón**: Service Layer Pattern
- **Gestión de Estado**: setState con StatefulWidget
- **Comunicación**: HTTP REST API
- **Persistencia**: SharedPreferences para datos locales

### Seguridad
- Autenticación JWT
- Validación de entrada de datos
- Manejo seguro de tokens
- Limpieza automática de sesiones

### Performance
- Paginación eficiente
- Carga lazy de imágenes
- Caché de datos frecuentes
- Optimización de builds

### Compatibilidad
- Multiplataforma (Android, iOS, Web, Desktop)
- Responsive design
- Soporte para diferentes densidades de pantalla

## 👨‍💻 Desarrollo y Contribución

### Configuración del Entorno de Desarrollo

1. **Instalar Flutter**
```bash
# Verificar instalación
flutter doctor -v
```

2. **Configurar IDE**
- VS Code: Instalar extensiones Flutter y Dart
- Android Studio: Instalar plugins Flutter y Dart

3. **Configurar Emuladores**
```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en emulador específico
flutter run -d "device_name"
```

### Estándares de Código

- Usar `flutter_lints` para mantener calidad del código
- Seguir las convenciones de nomenclatura de Dart
- Documentar funciones públicas
- Mantener archivos menores a 500 líneas

### Testing

```bash
# Ejecutar todos los tests
flutter test

# Ejecutar tests específicos
flutter test test/widget_test.dart

# Generar reporte de cobertura
flutter test --coverage
```

### Build de Producción

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release
```

## 🔍 Solución de Problemas

### Problemas Comunes

#### 1. Error de Conexión a la API
```
Solution: Verificar la URL del servidor y conectividad de red
- Revisar configuración de _baseUrl en los services
- Verificar que el servidor esté ejecutándose
- Comprobar configuración de red en dispositivo/emulador
```

#### 2. Problemas de Autenticación
```
Solution: Limpiar datos de sesión
- Usar el botón "Cerrar Sesión" en la app
- O ejecutar: flutter clean && flutter pub get
```

#### 3. Errores de Build
```
Solution: Limpiar proyecto y reinstalar dependencias
flutter clean
flutter pub get
flutter pub upgrade
```

#### 4. Problemas de Permisos (Android)
```
Solution: Verificar permisos en AndroidManifest.xml
- INTERNET
- WRITE_EXTERNAL_STORAGE (para impresión)
```

### Logs y Debugging

```bash
# Ver logs en tiempo real
flutter logs

# Ejecutar con debug detallado
flutter run --verbose

# Generar build con información de debug
flutter build apk --debug
```

## 📞 Soporte

Si encuentras algún problema:

1. **Revisa la documentación** en este README
2. **Verifica los logs** de la aplicación
3. **Comprueba la conectividad** con el servidor
4. **Consulta los issues** en el repositorio
5. **Crea un nuevo issue** con información detallada

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.

---

**Desarrollado con ❤️ usando Flutter**

*Última actualización: Julio 2025*

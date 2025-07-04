# 🤝 Guía de Contribución

## Bienvenido al Proyecto Shop Cart

Gracias por tu interés en contribuir a este proyecto. Esta guía te ayudará a configurar el entorno de desarrollo y seguir las mejores prácticas.

## 📋 Antes de Empezar

### Prerequisitos
- Flutter SDK >= 3.7.2
- Dart SDK >= 3.0.0
- Git configurado
- IDE configurado (VS Code o Android Studio)

### Configuración Inicial
1. Fork el repositorio
2. Clona tu fork localmente
3. Crea una rama para tu feature: `git checkout -b feature/nueva-funcionalidad`

## 🔧 Configuración del Entorno

### 1. Verificar Flutter
```bash
flutter doctor -v
```

### 2. Instalar Dependencias
```bash
flutter pub get
```

### 3. Configurar Variables de Entorno
Crea un archivo `.env` o configura las URLs de API en los servicios:
```dart
static const String _baseUrl = 'https://tu-api-development.com';
```

## 📝 Estándares de Código

### Naming Conventions
- **Archivos**: `snake_case.dart`
- **Clases**: `PascalCase`
- **Variables/Funciones**: `camelCase`
- **Constantes**: `UPPER_SNAKE_CASE`

### Estructura de Archivos
```
lib/
├── models/          # Modelos de datos
├── screens/         # Pantallas/Vistas
├── services/        # Lógica de negocio y API
├── widgets/         # Widgets reutilizables
└── utils/          # Utilidades y helpers
```

### Reglas de Código
- Usar `flutter_lints` (ya configurado)
- Máximo 120 caracteres por línea
- Documentar funciones públicas
- Evitar archivos > 500 líneas

## 🧪 Testing

### Ejecutar Tests
```bash
# Todos los tests
flutter test

# Tests específicos
flutter test test/specific_test.dart

# Con cobertura
flutter test --coverage
```

### Escribir Tests
```dart
// Ejemplo de test para widgets
testWidgets('Login button should be disabled when fields are empty', (tester) async {
  await tester.pumpWidget(MyApp());
  
  final loginButton = find.byType(ElevatedButton);
  expect(loginButton, findsOneWidget);
  
  // Verificar que el botón está deshabilitado
  final ElevatedButton button = tester.widget(loginButton);
  expect(button.onPressed, isNull);
});
```

## 🔄 Workflow de Contribución

### 1. Crear Issue
- Describe el problema o feature
- Incluye capturas de pantalla si es necesario
- Etiqueta apropiadamente

### 2. Desarrollo
```bash
# Crear rama
git checkout -b feature/descripcion-corta

# Hacer cambios
# Commit frecuente con mensajes descriptivos
git commit -m "feat: agregar validación de email en login"

# Push a tu fork
git push origin feature/descripcion-corta
```

### 3. Pull Request
- Título descriptivo
- Descripción detallada de cambios
- Screenshots si hay cambios visuales
- Referencia al issue relacionado

## 📦 Tipos de Contribución

### 🐛 Bug Fixes
- Describe el problema claramente
- Incluye pasos para reproducir
- Proporciona la solución

### ✨ New Features
- Discute la feature en un issue primero
- Mantén el alcance pequeño y enfocado
- Incluye tests para nueva funcionalidad

### 📚 Documentation
- Mejoras al README
- Comentarios en código
- Guías de usuario

### 🎨 UI/UX Improvements
- Incluye before/after screenshots
- Mantén consistencia con Material Design
- Considera accesibilidad

## 🚀 Consideraciones Específicas del Proyecto

### Autenticación
- Siempre manejar tokens JWT de forma segura
- Implementar logout limpio
- Validar sesiones expiradas

### API Calls
- Usar el patrón de services existente
- Manejar errores de red apropiadamente
- Implementar timeouts

### UI/UX
- Usar loading states
- Implementar feedback visual
- Mantener consistencia de diseño

### Impresión
- Usar el servicio nativo de impresión
- Generar PDFs con formato correcto
- Validar antes de imprimir

## 🔍 Code Review Checklist

### Antes de Enviar PR
- [ ] Código compila sin errores
- [ ] Tests pasan
- [ ] Lints no muestran errores
- [ ] Funcionalidad probada manualmente
- [ ] Documentación actualizada

### Para Reviewers
- [ ] Código sigue estándares del proyecto
- [ ] Lógica es clara y mantenible
- [ ] No hay vulnerabilidades de seguridad
- [ ] Performance es aceptable
- [ ] Tests cubren casos edge

## 🐛 Debugging

### Logs Útiles
```dart
// Para desarrollo
print('Debug: ${variable}');

// Para producción (usar con moderación)
debugPrint('Info: ${mensaje}');
```

### Herramientas de Debug
```bash
# Flutter Inspector
flutter run --debug

# Performance profiling
flutter run --profile

# Logs detallados
flutter logs -v
```

## 📞 Comunicación

### Donde Pedir Ayuda
- Issues de GitHub para bugs
- Discussions para preguntas generales
- Code review comments para feedback específico

### Etiqueta en Issues
- `bug`: Problemas o errores
- `enhancement`: Nuevas funcionalidades
- `documentation`: Mejoras a documentación
- `good first issue`: Ideal para principiantes
- `help wanted`: Necesita ayuda de la comunidad

## 📄 Commit Messages

Usar [Conventional Commits](https://www.conventionalcommits.org/):

```
feat: add email validation to login form
fix: resolve crash when loading products
docs: update README with setup instructions
style: fix formatting in user_service.dart
refactor: simplify authentication logic
test: add unit tests for client service
```

## 🎯 Roadmap

### Próximas Funcionalidades
- [ ] Sincronización offline
- [ ] Reportes avanzados
- [ ] Notificaciones push
- [ ] Multi-idioma
- [ ] Tema oscuro

### Mejoras Técnicas
- [ ] Migración a BLoC pattern
- [ ] Implementar CI/CD
- [ ] Añadir más tests
- [ ] Optimización de performance

---

**¡Gracias por contribuir al proyecto! 🚀**

*Si tienes preguntas, no dudes en crear un issue o discussion.*

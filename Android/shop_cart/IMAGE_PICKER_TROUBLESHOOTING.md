# Solución de Problemas - Image Picker

## Error de Canal de Comunicación

### Síntomas
- Error: `Unable to establish connection on channel`
- Error: `PlatformException(channel error, Unable to establish connection...)`
- La selección de imágenes no funciona

### Causas Principales
1. **Plugin no inicializado correctamente**: El plugin nativo no se ha conectado con Flutter
2. **Permisos insuficientes**: Los permisos de cámara/almacenamiento no están habilitados
3. **Cache corrupto**: Los archivos de cache están dañados
4. **Versión de plugin incompatible**: Problemas de compatibilidad entre versiones

### Soluciones Implementadas

#### 1. **Reintentos Inteligentes**
- El sistema intenta la operación hasta 3 veces
- Espera 2 segundos entre intentos
- Resetea el canal de comunicación en caso de error

#### 2. **Método de Fallback**
- Si el método principal falla, usa configuración más básica
- Reduce la calidad de imagen para minimizar la carga
- Maneja errores específicos del canal

#### 3. **Manejo Robusto de Errores**
- Identifica errores específicos (permisos, canal, timeout)
- Proporciona mensajes de error claros al usuario
- Ofrece opciones de solución

#### 4. **UI Mejorada**
- Diálogo de error específico para problemas de canal
- Guía de solución de problemas paso a paso
- Botones de reintento y ayuda

### Configuración de Android

#### Permisos (AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
```

#### FileProvider (AndroidManifest.xml)
```xml
<provider
    android:name="androidx.core.content.FileProvider"
    android:authorities="${applicationId}.flutter.image_provider"
    android:exported="false"
    android:grantUriPermissions="true">
    <meta-data
        android:name="android.support.FILE_PROVIDER_PATHS"
        android:resource="@xml/file_paths" />
</provider>
```

#### Rutas de Archivos (file_paths.xml)
```xml
<paths>
    <external-files-path name="my_images" path="Pictures" />
    <external-cache-path name="my_cache" path="." />
    <cache-path name="cached_files" path="." />
    <files-path name="internal_files" path="." />
    <external-path name="external_files" path="." />
</paths>
```

### Pasos de Solución para el Usuario

1. **Verificar Permisos**
   - Ir a Configuración > Aplicaciones > Shop Cart > Permisos
   - Habilitar Cámara y Almacenamiento

2. **Reiniciar la Aplicación**
   - Cerrar completamente la app
   - Volver a abrirla

3. **Liberar Espacio**
   - Verificar que haya espacio suficiente en el dispositivo
   - Limpiar cache si es necesario

4. **Probar Fuente Alternativa**
   - Si la cámara no funciona, probar galería
   - Si la galería no funciona, probar cámara

5. **Reiniciar Dispositivo**
   - Como última opción, reiniciar el dispositivo

### Prevención

1. **Mantener Dependencias Actualizadas**
   - Usar versiones estables de image_picker
   - Probar en dispositivos reales antes de lanzar

2. **Validar Permisos Antes de Usar**
   - Verificar permisos antes de llamar al plugin
   - Mostrar diálogos explicativos si se deniegan

3. **Manejo de Estados Robusto**
   - Verificar que el widget esté montado antes de setState
   - Manejar errores de forma graceful

4. **Testing Exhaustivo**
   - Probar en diferentes versiones de Android
   - Probar con y sin permisos
   - Probar en dispositivos con poco espacio

### Código de Ejemplo

```dart
// Uso correcto con manejo de errores
try {
  final imageUrl = await ImageService.selectAndUploadProfilePicture(
    source: ImageSource.gallery
  );
  if (imageUrl != null) {
    // Éxito
  }
} catch (e) {
  if (e.toString().contains('comunicación')) {
    // Mostrar diálogo específico para errores de canal
    showChannelErrorDialog();
  } else {
    // Mostrar error genérico
    showErrorSnackBar(e.toString());
  }
}
```

### Monitoreo

- Los errores se registran en logs para análisis
- Se incluye información específica del error (código, mensaje)
- Se rastrea el número de intentos y tiempo de respuesta

### Contacto de Soporte

Si el problema persiste después de seguir todos los pasos, contactar al equipo de desarrollo con:
- Modelo de dispositivo
- Versión de Android
- Pasos exactos para reproducir el error
- Screenshots del error

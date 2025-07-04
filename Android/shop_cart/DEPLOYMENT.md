# 🚀 Guía de Deployment

Esta guía te ayudará a desplegar la aplicación Shop Cart en diferentes plataformas y entornos.

## 📋 Tabla de Contenidos

- [Preparación para Producción](#-preparación-para-producción)
- [Android](#-android)
- [iOS](#-ios)
- [Web](#-web)
- [Desktop](#-desktop)
- [Variables de Entorno](#-variables-de-entorno)
- [CI/CD](#-cicd)
- [Monitoreo](#-monitoreo)

## 🔧 Preparación para Producción

### 1. Configuración de Variables
```dart
// lib/config/app_config.dart
class AppConfig {
  static const String apiBaseUrl = 'https://api.tu-dominio.com';
  static const String appName = 'Shop Cart';
  static const String appVersion = '1.0.0';
  static const bool isDebugMode = false;
}
```

### 2. Optimización de Assets
```bash
# Optimizar imágenes
flutter pub run flutter_launcher_icons:main

# Generar iconos adaptativos
flutter pub run flutter_launcher_icons:generate
```

### 3. Verificación Pre-deployment
```bash
# Análisis de código
flutter analyze

# Tests
flutter test

# Verificar warnings
flutter build --debug --verbose
```

## 📱 Android

### Configuración Inicial

#### 1. Configurar Keystore
```bash
# Generar keystore
keytool -genkey -v -keystore ~/shop-cart-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias shop-cart

# Crear key.properties
echo "storePassword=tu_password
keyPassword=tu_password
keyAlias=shop-cart
storeFile=../shop-cart-key.jks" > android/key.properties
```

#### 2. Configurar build.gradle
```gradle
// android/app/build.gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        applicationId "com.tuempresa.shop_cart"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

#### 3. Configurar Permisos
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
```

### Build y Deployment

#### APK para Testing
```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

#### App Bundle para Play Store
```bash
# Release App Bundle
flutter build appbundle --release

# Ubicación del archivo
# build/app/outputs/bundle/release/app-release.aab
```

#### Subir a Play Store
1. Abrir [Google Play Console](https://play.google.com/console)
2. Crear nueva aplicación
3. Completar información de la tienda
4. Subir App Bundle
5. Configurar precios y distribución
6. Enviar para revisión

## 🍎 iOS

### Configuración Inicial

#### 1. Configurar Xcode
```bash
# Abrir proyecto iOS
open ios/Runner.xcworkspace
```

#### 2. Configurar Bundle Identifier
```
// ios/Runner/Info.plist
<key>CFBundleIdentifier</key>
<string>com.tuempresa.shopCart</string>
```

#### 3. Configurar Signing
- Seleccionar Team en Xcode
- Configurar Provisioning Profile
- Verificar Bundle Identifier único

### Build y Deployment

#### Build para Testing
```bash
# Debug build
flutter build ios --debug

# Release build
flutter build ios --release
```

#### Subir a App Store
```bash
# Archive desde Xcode
# Product -> Archive

# O usar command line
flutter build ios --release
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -destination generic/platform=iOS -archivePath Runner.xcarchive archive
```

#### App Store Connect
1. Abrir [App Store Connect](https://appstoreconnect.apple.com)
2. Crear nueva app
3. Completar metadata
4. Subir build con Xcode Organizer
5. Configurar precios y disponibilidad
6. Enviar para revisión

## 🌐 Web

### Configuración

#### 1. Configurar web/index.html
```html
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta content="IE=Edge" http-equiv="X-UA-Compatible">
    <meta name="description" content="Shop Cart - Sistema de Facturación">
    <meta name="apple-mobile-web-app-capable" content="yes">
    <meta name="apple-mobile-web-app-status-bar-style" content="black">
    <meta name="apple-mobile-web-app-title" content="Shop Cart">
    <link rel="apple-touch-icon" href="icons/Icon-192.png">
    <link rel="icon" type="image/png" href="favicon.png"/>
    <title>Shop Cart</title>
</head>
<body>
    <div id="loading"></div>
    <script src="flutter.js" defer></script>
</body>
</html>
```

### Build y Deployment

#### Build para Producción
```bash
# Build web
flutter build web --release

# Build con base-href personalizado
flutter build web --release --base-href /shop-cart/
```

#### Deployment Options

##### 1. GitHub Pages
```bash
# Crear gh-pages branch
git checkout -b gh-pages
git add build/web/*
git commit -m "Deploy to GitHub Pages"
git push origin gh-pages
```

##### 2. Netlify
```bash
# Drag & drop build/web folder
# O configurar continuous deployment
```

##### 3. Firebase Hosting
```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Inicializar proyecto
firebase init hosting

# Deploy
firebase deploy
```

##### 4. Servidor Web Tradicional
```bash
# Copiar contenido de build/web/ al servidor
rsync -avz build/web/ user@server:/var/www/shop-cart/
```

## 💻 Desktop

### Windows

#### Build
```bash
# Build Windows
flutter build windows --release

# Ubicación: build/windows/runner/Release/
```

#### Distribución
- Crear instalador con [Inno Setup](https://jrsoftware.org/isinfo.php)
- O comprimir carpeta Release para distribución

### macOS

#### Build
```bash
# Build macOS
flutter build macos --release

# Ubicación: build/macos/Build/Products/Release/
```

#### Distribución
- Crear DMG para distribución
- Notarizar app para distribución fuera de App Store

### Linux

#### Build
```bash
# Build Linux
flutter build linux --release

# Ubicación: build/linux/x64/release/bundle/
```

#### Distribución
- Crear AppImage
- Crear paquete .deb/.rpm
- Distribuir como snap

## 🔧 Variables de Entorno

### Configuración por Ambiente

#### development.dart
```dart
class Config {
  static const String apiBaseUrl = 'http://localhost:3000';
  static const String environment = 'development';
  static const bool debugMode = true;
}
```

#### production.dart
```dart
class Config {
  static const String apiBaseUrl = 'https://api.produccion.com';
  static const String environment = 'production';
  static const bool debugMode = false;
}
```

### Build con Variables
```bash
# Development
flutter build apk --dart-define=ENVIRONMENT=development

# Production
flutter build apk --dart-define=ENVIRONMENT=production
```

## 🔄 CI/CD

### GitHub Actions

#### .github/workflows/build.yml
```yaml
name: Build and Deploy

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.7.2'
    
    - name: Install dependencies
      run: flutter pub get
    
    - name: Analyze code
      run: flutter analyze
    
    - name: Run tests
      run: flutter test
    
    - name: Build APK
      run: flutter build apk --release
    
    - name: Upload APK
      uses: actions/upload-artifact@v2
      with:
        name: app-release.apk
        path: build/app/outputs/flutter-apk/app-release.apk
```

### GitLab CI

#### .gitlab-ci.yml
```yaml
image: cirrusci/flutter:latest

stages:
  - test
  - build
  - deploy

test:
  stage: test
  script:
    - flutter pub get
    - flutter analyze
    - flutter test

build_android:
  stage: build
  script:
    - flutter build apk --release
  artifacts:
    paths:
      - build/app/outputs/flutter-apk/app-release.apk

deploy_web:
  stage: deploy
  script:
    - flutter build web --release
    - firebase deploy
```

## 📊 Monitoreo

### Crash Reporting
```dart
// main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  
  runZonedGuarded(() {
    runApp(MyApp());
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack);
  });
}
```

### Analytics
```dart
// Implementar Google Analytics o Firebase Analytics
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }
}
```

## 🔍 Troubleshooting

### Problemas Comunes

#### Android
- **Keystore issues**: Verificar rutas y passwords
- **Permissions**: Revisar AndroidManifest.xml
- **Build failures**: Limpiar con `flutter clean`

#### iOS
- **Signing issues**: Verificar certificates y profiles
- **Bundle ID conflicts**: Usar ID único
- **Archive failures**: Verificar Xcode settings

#### Web
- **CORS issues**: Configurar headers en servidor
- **Route issues**: Configurar server rewrites
- **Performance**: Optimizar assets y lazy loading

## 📞 Soporte

- **Documentation**: Revisar este archivo
- **Issues**: Crear issue en GitHub
- **Community**: Buscar en Stack Overflow
- **Official**: Consultar documentación de Flutter

---

**¡Deployment exitoso! 🎉**

*Última actualización: Julio 2025*

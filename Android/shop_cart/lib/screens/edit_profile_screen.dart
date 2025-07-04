import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/client.dart';
import '../services/image_service.dart';
import '../theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  final Client client;

  const EditProfileScreen({
    Key? key,
    required this.client,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cedulaController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isLoading = false;
  bool _isUploadingImage = false;
  String? _newProfileImageUrl;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _cedulaController.text = widget.client.cedula;
    _firstNameController.text = widget.client.firstName;
    _lastNameController.text = widget.client.lastName;
    _emailController.text = widget.client.email;
    _phoneController.text = widget.client.phone;
    _addressController.text = widget.client.address;
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: Text(
              'Guardar',
              style: TextStyle(
                color: _isLoading ? AppColors.textSecondary : AppColors.secondaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header informativo
              Card(
                color: AppColors.backgroundLight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.accentColor,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Puedes actualizar tu nombre, apellido, teléfono y dirección. La cédula y email no se pueden modificar.',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sección de foto de perfil
              _buildProfilePictureSection(),
              const SizedBox(height: 24),

              // Formulario
              _buildFormSection(),
              const SizedBox(height: 32),

              // Botones de acción
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection() {
    final currentImageUrl = _newProfileImageUrl ?? widget.client.picture;
    
    print('=== _buildProfilePictureSection DEBUG ===');
    print('_newProfileImageUrl: $_newProfileImageUrl');
    print('widget.client.picture: ${widget.client.picture}');
    print('currentImageUrl (final): $currentImageUrl');
    print('Timestamp: ${DateTime.now()}');
    
    return Card(
      color: AppColors.backgroundLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Foto de Perfil',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Center(
              child: Column(
                children: [
                  // Avatar con imagen actual
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: AppColors.accentColor.withOpacity(0.1),
                        backgroundImage: currentImageUrl != null && currentImageUrl.isNotEmpty
                            ? NetworkImage(currentImageUrl)
                            : null,
                        child: currentImageUrl == null || currentImageUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                size: 60,
                                color: AppColors.accentColor,
                              )
                            : null,
                      ),
                      
                      // Botón de cámara para cambiar foto
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.accentColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.backgroundLight,
                              width: 2,
                            ),
                          ),
                          child: IconButton(
                            icon: _isUploadingImage
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.backgroundLight,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.camera_alt,
                                    color: AppColors.backgroundLight,
                                    size: 20,
                                  ),
                            onPressed: _isUploadingImage ? null : _selectAndUploadProfilePicture,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Toca el ícono de cámara para cambiar tu foto',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      color: AppColors.backgroundLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Información Personal',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Cédula (Solo lectura)
            _buildReadOnlyField(
              controller: _cedulaController,
              label: 'Cédula',
              icon: Icons.badge,
              helperText: 'Este campo no se puede modificar',
            ),
            const SizedBox(height: 16),

            // Nombre (Editable)
            _buildTextField(
              controller: _firstNameController,
              label: 'Nombre',
              icon: Icons.person,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (value.trim().length < 2) {
                  return 'El nombre debe tener al menos 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Apellido (Editable)
            _buildTextField(
              controller: _lastNameController,
              label: 'Apellido',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El apellido es obligatorio';
                }
                if (value.trim().length < 2) {
                  return 'El apellido debe tener al menos 2 caracteres';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Email (Solo lectura)
            _buildReadOnlyField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email,
              helperText: 'Este campo no se puede modificar',
            ),
            const SizedBox(height: 16),

            // Teléfono
            _buildTextField(
              controller: _phoneController,
              label: 'Teléfono',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El teléfono es obligatorio';
                }
                if (value.trim().length < 7) {
                  return 'El teléfono debe tener al menos 7 dígitos';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Dirección
            _buildTextField(
              controller: _addressController,
              label: 'Dirección',
              icon: Icons.location_on,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La dirección es obligatoria';
                }
                if (value.trim().length < 5) {
                  return 'La dirección debe tener al menos 5 caracteres';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      enabled: !_isLoading,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.accentColor),
        filled: true,
        fillColor: AppColors.secondaryColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accentColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        labelStyle: TextStyle(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(color: AppColors.textPrimary),
    );
  }

  Widget _buildReadOnlyField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          enabled: false, // Campo de solo lectura
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: AppColors.textSecondary),
            filled: true,
            fillColor: AppColors.backgroundLight.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.borderColor.withOpacity(0.5)),
            ),
            labelStyle: TextStyle(color: AppColors.textSecondary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: TextStyle(color: AppColors.textSecondary),
        ),
        if (helperText != null) ...[
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Row(
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  helperText,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón Guardar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentColor,
              foregroundColor: AppColors.backgroundLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.backgroundLight,
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Guardar Cambios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),

        // Botón Cancelar
        SizedBox(
          width: double.infinity,
          height: 50,
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: AppColors.borderColor),
              ),
            ),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Determinar la URL de imagen final a usar
      final finalImageUrl = _newProfileImageUrl ?? widget.client.picture;
      
      print('=== _saveProfile DEBUG ANTES ===');
      print('_newProfileImageUrl: $_newProfileImageUrl');
      print('widget.client.picture: ${widget.client.picture}');
      print('finalImageUrl que se usará: $finalImageUrl');
      
      // Si hay una nueva imagen, actualizar en la base de datos
      if (_newProfileImageUrl != null) {
        print('Actualizando foto de perfil en la base de datos...');
        await ImageService.updateProfilePicture(_newProfileImageUrl!);
        print('Foto de perfil actualizada exitosamente en la base de datos');
      }
      
      // Crear cliente actualizado para retornar
      final updatedClient = widget.client.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        picture: finalImageUrl,
      );

      print('=== _saveProfile DEBUG DESPUÉS ===');
      print('updatedClient.picture: ${updatedClient.picture}');
      print('updatedClient completo: $updatedClient');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _newProfileImageUrl != null 
                ? 'Perfil actualizado correctamente, incluyendo la nueva foto.'
                : 'Cambios guardados exitosamente.'
            ),
            backgroundColor: AppColors.accentColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );

        // Regresar con el cliente actualizado
        Navigator.of(context).pop(updatedClient);
      }    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        // Provide more specific guidance based on error type
        String additionalInfo = '';
        if (errorMessage.contains('servidor no está disponible') || 
            errorMessage.contains('Connection reset') ||
            errorMessage.contains('endpoint')) {
          additionalInfo = '\n\nEsto indica que el backend no tiene implementado el endpoint para actualizar perfil. Contacta al administrador del sistema.';
        } else if (errorMessage.contains('Tiempo de espera')) {
          additionalInfo = '\n\nVerifica tu conexión a internet e inténtalo nuevamente.';
        } else if (errorMessage.contains('SSL') || errorMessage.contains('TLS')) {
          additionalInfo = '\n\nHay un problema con la seguridad del servidor. Contacta al administrador del sistema.';
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundLight,
            title: Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Error de Conexión',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
            content: Text(
              '$errorMessage$additionalInfo',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Aceptar',
                  style: TextStyle(color: AppColors.accentColor),
                ),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _selectAndUploadProfilePicture() async {
    try {
      // Mostrar opciones para seleccionar fuente
      final ImageSource? source = await _showImageSourceDialog();
      if (source == null) return;

      setState(() {
        _isUploadingImage = true;
      });

      // Mostrar progreso detallado
      _showProgressDialog();

      // Usar el servicio de imágenes para solo subir la imagen (sin actualizar BD)
      final imageUrl = await ImageService.selectAndUploadImageOnly(source: source);
      
      // Cerrar diálogo de progreso
      if (mounted) Navigator.of(context).pop();
      
      if (imageUrl != null) {
        print('=== _selectAndUploadProfilePicture DEBUG ===');
        print('Nueva imageUrl recibida: $imageUrl');
        print('_newProfileImageUrl antes del setState: $_newProfileImageUrl');
        
        setState(() {
          _newProfileImageUrl = imageUrl;
        });
        
        print('_newProfileImageUrl después del setState: $_newProfileImageUrl');
        
        // Mostrar mensaje que indica que la imagen está lista para guardar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Foto subida exitosamente. Presiona "Guardar" para actualizar tu perfil.'),
            backgroundColor: AppColors.accentColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de progreso si está abierto
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      
      String errorMessage = e.toString();
      
      // Mostrar mensaje de error más específico
      if (errorMessage.contains('comunicación') || errorMessage.contains('no está disponible')) {
        _showChannelErrorDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar foto: ${errorMessage.replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: AppColors.backgroundLight,
              onPressed: _selectAndUploadProfilePicture,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  void _showProgressDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: AppColors.primaryColor),
            const SizedBox(height: 16),
            const Text('Procesando imagen...'),
            const SizedBox(height: 8),
            Text(
              'Verificando plugin, seleccionando imagen y subiendo al servidor',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showChannelErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Error de Comunicación'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hay un problema de comunicación con el plugin de imagen.'),
            const SizedBox(height: 16),
            const Text('Para solucionarlo:'),
            const SizedBox(height: 8),
            const Text('1. Reinicia la aplicación completamente'),
            const Text('2. Verifica que los permisos estén habilitados'),
            const Text('3. Intenta usar una fuente diferente (cámara/galería)'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _testImagePickerPlugin();
            },
            child: Text('Diagnóstico', style: TextStyle(color: AppColors.accentColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showTroubleshootingDialog();
            },
            child: Text('Ver Ayuda', style: TextStyle(color: AppColors.accentColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _selectAndUploadProfilePicture();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: AppColors.backgroundLight,
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showTroubleshootingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            const Text('Solución de Problemas'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Si tienes problemas para seleccionar una imagen:'),
              const SizedBox(height: 16),
              _buildTroubleshootingStep('1', 'Verifica los permisos'),
              _buildTroubleshootingStep('2', 'Reinicia la aplicación'),
              _buildTroubleshootingStep('3', 'Libera espacio de almacenamiento'),
              _buildTroubleshootingStep('4', 'Prueba con la otra fuente (cámara/galería)'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info, color: AppColors.accentColor, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Si el problema persiste, contacta al soporte técnico.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingStep(String step, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(description),
          ),
        ],
      ),
    );
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          'Seleccionar foto',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿De dónde quieres seleccionar la foto?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Cámara'),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentColor),
          ),
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text('Galería'),
            style: TextButton.styleFrom(foregroundColor: AppColors.accentColor),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Future<void> _testImagePickerPlugin() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.backgroundLight,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primaryColor),
              const SizedBox(height: 16),
              const Text('Ejecutando diagnóstico...'),
            ],
          ),
        ),
      );

      // Ejecutar pruebas de diagnóstico
      final results = <String>[];
      
      // Prueba 1: Verificar disponibilidad
      try {
        final isAvailable = await ImageService.isImagePickerAvailable();
        results.add('✓ Plugin disponible: ${isAvailable ? 'SÍ' : 'NO'}');
      } catch (e) {
        results.add('✗ Error verificando plugin: $e');
      }

      // Prueba 2: Intentar inicialización
      try {
        final initialized = await ImageService.initializeImagePicker();
        results.add('✓ Inicialización: ${initialized ? 'EXITOSA' : 'FALLIDA'}');
      } catch (e) {
        results.add('✗ Error en inicialización: $e');
      }

      // Cerrar diálogo de progreso
      if (mounted) Navigator.of(context).pop();

      // Mostrar resultados
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.backgroundLight,
            title: Row(
              children: [
                Icon(Icons.bug_report, color: AppColors.primaryColor),
                const SizedBox(width: 8),
                const Text('Diagnóstico'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: results.map((result) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(result),
                )).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cerrar', style: TextStyle(color: AppColors.textSecondary)),
              ),
            ],
          ),
        );
      }

    } catch (e) {
      // Cerrar diálogo de progreso
      if (mounted) {
        try {
          Navigator.of(context).pop();
        } catch (_) {}
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en diagnóstico: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

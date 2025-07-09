import 'package:flutter/material.dart';
import '../services/client_service.dart';
import '../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Cambiar Contraseña'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header informativo
              _buildInfoCard(),
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

  Widget _buildInfoCard() {
    return Card(
      color: AppColors.backgroundLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: AppColors.accentColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Seguridad',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Para cambiar tu contraseña, necesitas ingresar tu contraseña actual y luego la nueva contraseña.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recomendaciones:',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            _buildRecommendation('• Usa al menos 8 caracteres'),
            _buildRecommendation('• Incluye mayúsculas y minúsculas'),
            _buildRecommendation('• Agrega números y símbolos'),
            _buildRecommendation('• No uses información personal'),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendation(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
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
              'Cambiar Contraseña',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),


            // Nueva contraseña
            _buildPasswordField(
              controller: _newPasswordController,
              label: 'Nueva Contraseña',
              icon: Icons.lock,
              obscureText: _obscureNewPassword,
              onToggleVisibility: () => setState(() {
                _obscureNewPassword = !_obscureNewPassword;
              }),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'La nueva contraseña es obligatoria';
                }
                if (value.length < 8) {
                  return 'La contraseña debe tener al menos 8 caracteres';
                }
                
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirmar contraseña
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'Confirmar Nueva Contraseña',
              icon: Icons.lock_reset,
              obscureText: _obscureConfirmPassword,
              onToggleVisibility: () => setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirma tu nueva contraseña';
                }
                if (value != _newPasswordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      enabled: !_isLoading,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.accentColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility : Icons.visibility_off,
            color: AppColors.textSecondary,
          ),
          onPressed: onToggleVisibility,
        ),
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Botón Cambiar Contraseña
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _changePassword,
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
                    'Cambiar Contraseña',
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

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await ClientService.changePassword(
        newPassword: _newPasswordController.text,
      );

      if (success) {
        if (mounted) {
          // Mostrar dialog de éxito
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              backgroundColor: AppColors.backgroundLight,
              title: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: AppColors.accentColor,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Éxito',
                    style: TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
              content: Text(
                'Tu contraseña ha sido cambiada correctamente.',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar dialog
                    Navigator.of(context).pop(); // Regresar a perfil
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentColor,
                    foregroundColor: AppColors.backgroundLight,
                  ),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      } else {
        throw Exception('No se pudo cambiar la contraseña');
      }    } catch (e) {
      if (mounted) {
        String errorMessage = e.toString().replaceAll('Exception: ', '');
        
        // Provide more specific guidance based on error type
        String additionalInfo = '';
        if (errorMessage.contains('servidor no está disponible') || 
            errorMessage.contains('Connection reset') ||
            errorMessage.contains('endpoint')) {
          additionalInfo = '\n\nEsto indica que el backend no tiene implementado el endpoint para cambiar contraseñas. Contacta al administrador del sistema.';
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
}

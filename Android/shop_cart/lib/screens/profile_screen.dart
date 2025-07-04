import 'package:flutter/material.dart';
import '../models/client.dart';
import '../services/client_service.dart';
import '../services/user_service.dart';
import 'edit_profile_screen.dart';
import 'change_password_screen.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onLogout;
  
  const ProfileScreen({Key? key, this.onLogout}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Client? _client;
  bool _isLoading = true;
  String? _error;
  DateTime? _lastUpdate; // Para controlar actualizaciones recientes

  @override
  void initState() {
    super.initState();
    _loadClientData();
  }
  Future<void> _loadClientData() async {
    // Si hay una actualización reciente (menos de 10 segundos), no recargar
    if (_lastUpdate != null && 
        DateTime.now().difference(_lastUpdate!).inSeconds < 10) {
      print('ProfileScreen: Evitando recarga reciente. Última actualización: ${_lastUpdate}');
      return;
    }
    
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('ProfileScreen: Iniciando carga de datos del cliente...');
      final client = await ClientService.getCurrentClient();
      print('ProfileScreen: Cliente obtenido: $client');
      
      setState(() {
        _client = client;
        _isLoading = false;
        if (client == null) {
          _error = 'No se pudo cargar la información del perfil. Verifica tu conexión y que tengas una sesión activa.';
        }
      });
    } catch (e) {
      print('ProfileScreen: Error al cargar cliente: $e');
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar el perfil: ${e.toString()}';
      });
    }
  }

  Future<void> _forceRefreshClientData() async {
    // Método para refresh manual que siempre recarga
    print('ProfileScreen: Refresh manual solicitado');
    _lastUpdate = null; // Resetear para permitir la recarga
    
    // Limpiar caché de imágenes antes de recargar
    _clearImageCache();
    
    await _loadClientData();
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundLight,
        title: Text(
          'Cerrar Sesión',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          '¿Estás seguro que deseas cerrar sesión?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      try {
        // Primero cerrar sesión en el servicio
        await UserService.logout();
        
        if (mounted) {
          if (widget.onLogout != null) {
            // Cerrar todas las pantallas abiertas y regresar a main
            Navigator.of(context).popUntil((route) => route.isFirst);
            // Llamar al callback que maneja el logout en main.dart
            widget.onLogout!();
          } else {
            // Si no hay callback, mostrar error
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error: No se pudo cerrar sesión correctamente'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        print('Error al cerrar sesión: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cerrar sesión: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// Limpia el caché de imágenes para forzar la recarga
  void _clearImageCache() {
    try {
      // Limpiar el caché de imágenes de red
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
      print('ProfileScreen: Caché de imágenes limpiado');
    } catch (e) {
      print('ProfileScreen: Error limpiando caché: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: AppColors.primaryColor,
        foregroundColor: AppColors.secondaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _forceRefreshClientData,
            tooltip: 'Recargar perfil',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.accentColor,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _forceRefreshClientData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentColor,
                foregroundColor: AppColors.backgroundLight,
              ),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_client == null) {
      return Center(
        child: Text(
          'No se pudo cargar la información del perfil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.accentColor,
      onRefresh: _forceRefreshClientData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [            // Header con información básica
            Card(
              color: AppColors.backgroundLight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _buildProfileAvatar(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_client!.firstName} ${_client!.lastName}',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _client!.email,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          if (_client!.clientId != 0) ...[
                            const SizedBox(height: 4),
                            Text(
                              'ID: ${_client!.clientId}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Información del perfil
            _buildSection(
              title: 'Información Personal',
              children: [
                _buildInfoItem('Cédula', _client!.cedula),
                _buildInfoItem('Nombre', _client!.firstName),
                _buildInfoItem('Apellido', _client!.lastName),
                _buildInfoItem('Email', _client!.email),
                _buildInfoItem('Teléfono', _client!.phone),
                _buildInfoItem('Dirección', _client!.address),
              ],
            ),
            const SizedBox(height: 24),

            // Acciones
            _buildSection(
              title: 'Acciones',
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  title: 'Editar Perfil',
                  subtitle: 'Actualizar información personal',
                  onTap: () => _navigateToEditProfile(),
                ),
                _buildActionButton(
                  icon: Icons.lock,
                  title: 'Cambiar Contraseña',
                  subtitle: 'Actualizar contraseña de acceso',
                  onTap: () => _navigateToChangePassword(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          color: AppColors.backgroundLight,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'No especificado',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: AppColors.accentColor,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _navigateToEditProfile() async {
    print('=== ProfileScreen: _navigateToEditProfile DEBUG ===');
    print('Cliente antes de navegar: ${_client?.picture}');
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(client: _client!),
      ),
    );

    print('=== ProfileScreen: Resultado recibido ===');
    print('result: $result');
    print('result es Client?: ${result is Client}');
    if (result is Client) {
      print('Cliente actualizado recibido: ${result.picture}');
    }

    if (result != null) {
      if (result is Client) {
        // Se recibió un cliente actualizado
        print('Actualizando cliente en ProfileScreen');
        
        // Limpiar caché de imágenes antes de actualizar
        _clearImageCache();
        
        setState(() {
          _client = result;
          _lastUpdate = DateTime.now(); // Marcar que acabamos de actualizar
        });
        
        print('Cliente actualizado en ProfileScreen: ${_client?.picture}');
        print('Marcado como actualizado en: $_lastUpdate');
        
        // Dar un poco de tiempo para que el servidor procese la actualización
        // y luego recargar para sincronizar con los datos del servidor
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            print('Recargando datos del servidor después de actualización...');
            _forceRefreshClientData();
          }
        });
        
        // NO volver a cargar desde el servidor, ya tenemos el cliente actualizado
        // No hacer: await _loadClientData();
        
        // Notificar a la pantalla anterior que hubo cambios
        if (mounted) {
          Navigator.of(context).pop(result);
        }
      } else if (result == true) {
        // Comportamiento antiguo (por si acaso)
        await _loadClientData();
        
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      }
    }
  }

  Future<void> _navigateToChangePassword() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    print('=== ProfileScreen: _buildProfileAvatar DEBUG ===');
    print('_client?.picture: ${_client?.picture}');
    print('Picture no es null?: ${_client?.picture != null}');
    print('Picture no está vacía?: ${_client?.picture?.isNotEmpty}');
    
    // Verificar si el cliente tiene una foto de perfil
    if (_client?.picture != null && _client!.picture!.isNotEmpty) {
      print('Mostrando imagen: ${_client!.picture}');
      
      // Agregar timestamp para evitar el caché
      final imageUrl = _client!.picture!.contains('?') 
          ? '${_client!.picture}&t=${DateTime.now().millisecondsSinceEpoch}'
          : '${_client!.picture}?t=${DateTime.now().millisecondsSinceEpoch}';
      
      print('URL con timestamp: $imageUrl');
      
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.accentColor,
            width: 2,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: AppColors.backgroundLight,
          radius: 30,
          child: ClipOval(
            child: Image.network(
              imageUrl,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
              // Evitar caché
              cacheWidth: null,
              cacheHeight: null,
              headers: {
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                'Pragma': 'no-cache',
                'Expires': '0',
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: AppColors.accentColor,
                      strokeWidth: 2.0,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                print('Error cargando imagen: $error');
                // Si hay error cargando la imagen, mostrar iniciales
                return _buildInitialsAvatar();
              },
            ),
          ),
        ),
      );
    } else {
      // Si no hay foto, mostrar iniciales
      return _buildInitialsAvatar();
    }
  }

  Widget _buildInitialsAvatar() {
    return CircleAvatar(
      backgroundColor: AppColors.accentColor,
      radius: 30,
      child: Text(
        _client!.firstName.isNotEmpty && _client!.lastName.isNotEmpty
            ? '${_client!.firstName[0]}${_client!.lastName[0]}'
            : 'U',
        style: TextStyle(
          color: AppColors.backgroundLight,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

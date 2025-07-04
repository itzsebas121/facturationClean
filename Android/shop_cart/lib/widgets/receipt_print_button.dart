import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/cart_service.dart';
import '../services/notification_service.dart';
import '../services/error_service.dart';

class ReceiptPrintButton extends StatelessWidget {
  final dynamic orderData;

  const ReceiptPrintButton({
    super.key,
    required this.orderData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _handlePrintReceipt(context),
          icon: const Icon(Icons.print),
          label: const Text('Imprimir Recibo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.primaryContainer,
            foregroundColor: AppTheme.lightTheme.colorScheme.onPrimaryContainer,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handlePrintReceipt(BuildContext context) async {
    try {
      // Mostrar indicador de carga
      NotificationService.showLoading(context, 'Preparando documento...');
      
      // Obtener el ID de la orden
      final orderId = orderData['orderId'] ?? orderData['OrderId'];
      
      if (orderId == null) {
        throw Exception('No se pudo obtener el ID de la orden');
      }
      
      // Llamar al servicio para generar y enviar a imprimir el PDF
      final result = await CartService.printReceipt(orderId);
      
      // Cerrar el indicador de carga
      NotificationService.hideLoading(context);
      
      if (result) {
        // Mostrar notificación de éxito
        NotificationService.showSuccess(
          context,
          'Documento enviado al servicio de impresión',
        );
      } else {
        // Mostrar notificación de error
        NotificationService.showError(
          context,
          'Error al preparar el documento para impresión',
        );
      }
    } catch (e) {
      // Registrar error para diagnóstico
      ErrorService.logError(
        message: 'Error al imprimir recibo',
        details: e.toString(),
        screen: 'OrderDetail',
        context: {'orderId': orderData['orderId'] ?? orderData['OrderId']},
      );
      
      // Cerrar el indicador de carga si está visible
      try {
        NotificationService.hideLoading(context);
      } catch (_) {
        // Ignore if dialog is not showing
      }
      
      // Determinar el tipo de error y mostrar mensaje apropiado
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      
      if (errorMessage.contains('No se encontraron items')) {
        NotificationService.showError(
          context,
          'Error: La orden no tiene productos para imprimir',
        );
      } else if (errorMessage.contains('No se pudo obtener el ID')) {
        // Error de datos
        NotificationService.showError(
          context,
          'Error: No se pudo identificar la orden',
        );
      } else {
        // Error genérico
        NotificationService.showError(
          context,
          'Error al preparar el documento: $errorMessage',
        );
      }
    }
  }
}

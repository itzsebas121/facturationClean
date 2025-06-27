import 'package:flutter/material.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChange;

  const PaginationWidget({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        border: Border(
          top: BorderSide(color: colorScheme.outline),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Información de página actual
            Text(
              'Página $currentPage de $totalPages',
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            // Botones de paginación numerada
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPaginationButtons(colorScheme),
            ),
            const SizedBox(height: 12),
            // Botones de navegación rápida
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Botón "Primera"
                ElevatedButton.icon(
                  onPressed: currentPage > 1 ? () => onPageChange(1) : null,
                  icon: const Icon(Icons.first_page, size: 18),
                  label: const Text('Primera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPage > 1 ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    foregroundColor: currentPage > 1 ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                // Botón "Anterior"
                ElevatedButton.icon(
                  onPressed: currentPage > 1 ? () => onPageChange(currentPage - 1) : null,
                  icon: const Icon(Icons.chevron_left, size: 18),
                  label: const Text('Anterior'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPage > 1 ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    foregroundColor: currentPage > 1 ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                // Botón "Siguiente"
                ElevatedButton.icon(
                  onPressed: currentPage < totalPages ? () => onPageChange(currentPage + 1) : null,
                  icon: const Icon(Icons.chevron_right, size: 18),
                  label: const Text('Siguiente'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPage < totalPages ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    foregroundColor: currentPage < totalPages ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                // Botón "Última"
                ElevatedButton.icon(
                  onPressed: currentPage < totalPages ? () => onPageChange(totalPages) : null,
                  icon: const Icon(Icons.last_page, size: 18),
                  label: const Text('Última'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: currentPage < totalPages ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                    foregroundColor: currentPage < totalPages ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Construye los botones de paginación numerada
  List<Widget> _buildPaginationButtons(ColorScheme colorScheme) {
    List<Widget> buttons = [];
    
    // Mostrar primera página si no estamos en ella
    if (currentPage > 1) {
      buttons.add(_buildPageButton(
        page: 1,
        label: '1',
        isActive: false,
        colorScheme: colorScheme,
      ));
      
      // Puntos suspensivos si hay páginas entre la primera y la actual
      if (currentPage > 3) {
        buttons.add(const SizedBox(width: 8));
        buttons.add(Text(
          '...',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ));
      }
      
      buttons.add(const SizedBox(width: 8));
    }
    
    // Página anterior (si no es la primera ni la segunda)
    if (currentPage > 2) {
      buttons.add(_buildPageButton(
        page: currentPage - 1,
        label: '${currentPage - 1}',
        isActive: false,
        colorScheme: colorScheme,
      ));
      buttons.add(const SizedBox(width: 8));
    }
    
    // Página actual (resaltada)
    buttons.add(_buildPageButton(
      page: currentPage,
      label: '$currentPage',
      isActive: true,
      colorScheme: colorScheme,
    ));
    
    // Página siguiente (si no es la última ni la penúltima)
    if (currentPage < totalPages - 1) {
      buttons.add(const SizedBox(width: 8));
      buttons.add(_buildPageButton(
        page: currentPage + 1,
        label: '${currentPage + 1}',
        isActive: false,
        colorScheme: colorScheme,
      ));
    }
    
    // Última página si no estamos en ella
    if (currentPage < totalPages) {
      // Puntos suspensivos si hay páginas entre la actual y la última
      if (currentPage < totalPages - 2) {
        buttons.add(const SizedBox(width: 8));
        buttons.add(Text(
          '...',
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 16,
          ),
        ));
      }
      
      buttons.add(const SizedBox(width: 8));
      buttons.add(_buildPageButton(
        page: totalPages,
        label: '$totalPages',
        isActive: false,
        colorScheme: colorScheme,
      ));
    }
    
    return buttons;
  }

  /// Construye un botón individual de página
  Widget _buildPageButton({
    required int page,
    required String label,
    required bool isActive,
    required ColorScheme colorScheme,
  }) {
    return GestureDetector(
      onTap: isActive ? null : () => onPageChange(page),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? colorScheme.primary : colorScheme.outline,
          ),
          boxShadow: isActive ? [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? colorScheme.onPrimary : colorScheme.onSurface,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaginationWidget extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final Function(int) onPageChange;

  const PaginationWidget({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Solo mostrar números de página: inicio, actual, y final
          _buildSimplePageNumbers(),
        ],
      ),
    );
  }

  Widget _buildSimplePageNumbers() {
    List<Widget> pageWidgets = [];
    
    // Si solo hay 1 página, mostrar solo esa
    if (totalPages <= 1) {
      pageWidgets.add(_buildPageButton(1));
      return Row(children: pageWidgets);
    }
    
    // Si hay 2 páginas, mostrar ambas
    if (totalPages == 2) {
      pageWidgets.add(_buildPageButton(1));
      pageWidgets.add(const SizedBox(width: 8));
      pageWidgets.add(_buildPageButton(2));
      return Row(children: pageWidgets);
    }
    
    // Si hay 3 o más páginas, mostrar: inicio, actual, final
    Set<int> pagesToShow = {};
    
    // Siempre mostrar la primera página
    pagesToShow.add(1);
    
    // Mostrar la página actual (si no es la primera ni la última)
    if (currentPage > 1 && currentPage < totalPages) {
      pagesToShow.add(currentPage);
    }
    
    // Siempre mostrar la última página
    pagesToShow.add(totalPages);
    
    // Convertir a lista ordenada
    List<int> pages = pagesToShow.toList()..sort();
    
    // Construir los botones
    for (int i = 0; i < pages.length; i++) {
      int page = pages[i];
      
      pageWidgets.add(_buildPageButton(page));
      
      // Agregar separador entre páginas
      if (i < pages.length - 1) {
        int nextPage = pages[i + 1];
        if (nextPage > page + 1) {
          // Hay salto, agregar puntos suspensivos
          pageWidgets.add(const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('...', style: TextStyle(fontSize: 16)),
          ));
        } else {
          // No hay salto, agregar espacio normal
          pageWidgets.add(const SizedBox(width: 8));
        }
      }
    }
    
    return Row(children: pageWidgets);
  }
  
  Widget _buildPageButton(int page) {
    final isCurrentPage = page == currentPage;
    
    return InkWell(
      onTap: () => onPageChange(page),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isCurrentPage
              ? AppTheme.lightTheme.colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isCurrentPage
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          '$page',
          style: TextStyle(
            color: isCurrentPage
                ? Colors.white
                : AppTheme.lightTheme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

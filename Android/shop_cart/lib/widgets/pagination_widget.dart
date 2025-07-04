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
          // Botón anterior
          IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: currentPage > 1
                ? () => onPageChange(currentPage - 1)
                : null,
            color: currentPage > 1
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.grey,
          ),
          
          // Páginas
          _buildPageNumbers(),
          
          // Botón siguiente
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios),
            onPressed: currentPage < totalPages
                ? () => onPageChange(currentPage + 1)
                : null,
            color: currentPage < totalPages
                ? AppTheme.lightTheme.colorScheme.primary
                : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildPageNumbers() {
    List<Widget> pageWidgets = [];
    
    // Determinar qué páginas mostrar
    List<int> pagesToShow = [];
    
    // Siempre mostrar la primera página
    pagesToShow.add(1);
    
    // Mostrar páginas cercanas a la actual
    for (int i = currentPage - 1; i <= currentPage + 1; i++) {
      if (i > 1 && i < totalPages) {
        pagesToShow.add(i);
      }
    }
    
    // Siempre mostrar la última página si hay más de una
    if (totalPages > 1) {
      pagesToShow.add(totalPages);
    }
    
    // Ordenar y eliminar duplicados
    pagesToShow = pagesToShow.toSet().toList()..sort();
    
    // Construir los widgets de página
    for (int i = 0; i < pagesToShow.length; i++) {
      int page = pagesToShow[i];
      
      // Agregar el botón de página
      pageWidgets.add(
        InkWell(
          onTap: () => onPageChange(page),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: page == currentPage
                  ? AppTheme.lightTheme.colorScheme.primary
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$page',
              style: TextStyle(
                color: page == currentPage
                    ? Colors.white
                    : AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
      
      // Agregar puntos suspensivos si hay saltos en la numeración
      if (i < pagesToShow.length - 1 && pagesToShow[i + 1] > page + 1) {
        pageWidgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('...'),
          ),
        );
      }
    }
    
    return Row(children: pageWidgets);
  }
}

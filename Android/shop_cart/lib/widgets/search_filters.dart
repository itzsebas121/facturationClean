import 'package:flutter/material.dart';
import '../models/category.dart';

class SearchFilters extends StatelessWidget {
  final List<Category> categories;
  final Function(String) onSearch;
  final Function(String?) onCategoryChange;
  final String searchTerm;
  final String? selectedCategory;
  final TextEditingController searchController;
  final VoidCallback onClearFilters;

  const SearchFilters({
    super.key,
    required this.categories,
    required this.onSearch,
    required this.onCategoryChange,
    required this.searchTerm,
    required this.selectedCategory,
    required this.searchController,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtros de búsqueda',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 12),
          
          // Barra de búsqueda
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchTerm.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        onSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            onSubmitted: onSearch,
            textInputAction: TextInputAction.search,
          ),
          const SizedBox(height: 12),
          
          // Selector de categoría
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            value: _getValidSelectedCategory(),
            items: [
              const DropdownMenuItem<String>(
                value: '',
                child: Text('Todas las categorías'),
              ),
              ...categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id.toString(),
                  child: Text(category.name),
                );
              }).toList(),
            ],
            onChanged: (String? newValue) {
              onCategoryChange(newValue == '' ? null : newValue);
            },
          ),
          
          const SizedBox(height: 12),
          
          // Botón para limpiar filtros
          Center(
            child: TextButton.icon(
              onPressed: onClearFilters,
              icon: const Icon(Icons.refresh),
              label: const Text('Limpiar filtros'),
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene un valor válido para el dropdown, evitando errores de valores no encontrados
  String _getValidSelectedCategory() {
    // Si selectedCategory es null o vacío, retornar el valor por defecto
    if (selectedCategory == null || selectedCategory!.isEmpty) {
      return '';
    }
    
    // Verificar si el valor existe en las categorías disponibles
    final categoryExists = categories.any((category) => category.id.toString() == selectedCategory);
    
    if (categoryExists) {
      return selectedCategory!;
    } else {
      // Si no existe, retornar el valor por defecto
      return '';
    }
  }
}

import 'package:flutter/material.dart';
import '../../models/category.dart';

class SearchFilters extends StatelessWidget {
  final List<Category> categories;
  final Function(String) onSearch;
  final Function(String) onCategoryChange;
  final String searchTerm;
  final String selectedCategory;
  final TextEditingController searchController;
  final VoidCallback onClearFilters;

  const SearchFilters({
    Key? key,
    required this.categories,
    required this.onSearch,
    required this.onCategoryChange,
    required this.searchTerm,
    required this.selectedCategory,
    required this.searchController,
    required this.onClearFilters,
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
          bottom: BorderSide(color: colorScheme.outline),
        ),
      ),
      child: Column(
        children: [
          // Campo de búsqueda
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Buscar productos...',
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        searchController.clear();
                        onSearch('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          // Selector de categoría
          DropdownButtonFormField<String>(
            value: selectedCategory.isNotEmpty ? selectedCategory : null,
            decoration: InputDecoration(
              labelText: 'Categoría',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colorScheme.primary, width: 2),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            isExpanded: true,
            items: [
              // Opción "Todas las categorías"
              DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'Todas las categorías',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // Categorías desde el endpoint
              ...categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category.id.toString(),
                  child: Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) {
              onCategoryChange(value ?? "");
            },
            dropdownColor: colorScheme.surface,
            style: TextStyle(color: colorScheme.onSurface),
          ),
          // Botón para limpiar filtros si hay filtros activos
          if (searchTerm.isNotEmpty || selectedCategory.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Filtros activos',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onClearFilters,
                  icon: Icon(
                    Icons.clear_all,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  label: Text(
                    'Limpiar filtros',
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

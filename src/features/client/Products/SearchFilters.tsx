"use client"

import type React from "react"
import { useState } from "react"
import type { Category } from "../../../types/Categorie"
import { Search, Folder, X, ChevronDown } from "lucide-react"
import "./SearchFilters.css"

interface SearchFiltersProps {
  categories: Category[]
  onSearch: (term: string) => void
  onCategoryChange: (categoryId: string) => void
  searchTerm: string
  selectedCategory: string
}

export function SearchFilters({
  categories,
  onSearch,
  onCategoryChange,
  searchTerm,
  selectedCategory,
}: SearchFiltersProps) {
  const [localSearchTerm, setLocalSearchTerm] = useState(searchTerm)

  const handleSearchSubmit = (e: React.FormEvent) => {
    e.preventDefault()
    onSearch(localSearchTerm)
  }

  const handleClearFilters = () => {
    setLocalSearchTerm("")
    onSearch("")
    onCategoryChange("")
  }

  const hasActiveFilters = searchTerm || selectedCategory

  return (
    <div className="search-filters">
      <div className="filters-content">
        <form onSubmit={handleSearchSubmit} className="search-form">
          <div className="search-input-container">
            <Search className="search-icon" size={18} />
            <input
              type="text"
              placeholder="Buscar productos..."
              value={localSearchTerm}
              onChange={(e) => setLocalSearchTerm(e.target.value)}
              className="search-input"
            />
            {localSearchTerm && (
              <button type="button" onClick={() => setLocalSearchTerm("")} className="clear-search-btn">
                <X size={16} />
              </button>
            )}
          </div>
          <button type="submit" className="search-submit-btn">
            Buscar
          </button>
        </form>

        <div className="category-filter">
          <label htmlFor="category-select" className="filter-label">
            <Folder size={16} />
            Categoría
          </label>
          <div className="select-container">
            <select
              id="category-select"
              value={selectedCategory}
              onChange={(e) => onCategoryChange(e.target.value)}
              className="category-select"
            >
              <option value="">Todas las categorías</option>
              {categories.map((category) => (
                <option key={category.id} value={category.id}>
                  {category.name}
                </option>
              ))}
            </select>
            <ChevronDown className="select-arrow" size={16} />
          </div>
        </div>

        {hasActiveFilters && (
          <button onClick={handleClearFilters} className="clear-all-btn">
            <X size={16} />
            Limpiar filtros
          </button>
        )}
      </div>

      {hasActiveFilters && (
        <div className="active-filters">
          <span className="active-filters-label">Filtros activos:</span>
          <div className="filter-tags">
            {searchTerm && (
              <span className="filter-tag">
                Búsqueda: "{searchTerm}"
                <button onClick={() => onSearch("")} className="remove-filter">
                  <X size={14} />
                </button>
              </span>
            )}
            {selectedCategory && (
              <span className="filter-tag">
                Categoría: {categories.find((c) => c.id === Number(selectedCategory))?.name}
                <button onClick={() => onCategoryChange("")} className="remove-filter">
                  <X size={14} />
                </button>
              </span>
            )}
          </div>
        </div>
      )}
    </div>
  )
}

"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { X, Save } from "lucide-react"
import type { Product } from "../../../types/Product"
import "./ProductModal.css"

interface Category {
  CategoryId: number
  CategoryName: string
}

interface ProductModalProps {
  product: Product | null
  categories: Category[]
  isOpen: boolean
  onClose: () => void
  onSave: (product: any) => void
  isCreating: boolean
  loading: boolean
}

export function ProductModal({ product, categories, isOpen, onClose, onSave, isCreating, loading }: ProductModalProps) {
  const [formData, setFormData] = useState({
    name: "",
    price: "",
    description: "",
    image: "",
    stock: "",
    categoryId: "",
  })

  const [errors, setErrors] = useState<Record<string, string>>({})

  useEffect(() => {
    if (product) {
      // Find category ID from category name
      const category = categories.find((cat) => cat.CategoryName === product.category)
      setFormData({
        name: product.name,
        price: product.price.toString(),
        description: product.description,
        image: product.image || "",
        stock: (product.stock || 0).toString(),
        categoryId: category ? category.CategoryId.toString() : "",
      })
    } else {
      setFormData({
        name: "",
        price: "",
        description: "",
        image: "",
        stock: "",
        categoryId: "",
      })
    }
    setErrors({})
  }, [product, categories, isOpen])

  const validateForm = () => {
    const newErrors: Record<string, string> = {}

    if (!formData.name.trim()) {
      newErrors.name = "El nombre es requerido"
    }

    if (!formData.price || Number.parseFloat(formData.price) <= 0) {
      newErrors.price = "El precio debe ser mayor a 0"
    }

    if (!formData.description.trim()) {
      newErrors.description = "La descripción es requerida"
    }

    if (!formData.stock || Number.parseInt(formData.stock) < 0) {
      newErrors.stock = "El stock no puede ser negativo"
    }

    if (!formData.categoryId) {
      newErrors.categoryId = "La categoría es requerida"
    }

    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault()

    if (!validateForm()) {
      return
    }

    onSave(formData)
  }

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }))

    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: "" }))
    }
  }

  if (!isOpen) return null

  return (
    <div className="product-modal__overlay" >
      <div className="product-modal__content" onClick={(e) => e.stopPropagation()}>
        <div className="product-modal__header">
          <h2 className="product-modal__title">{isCreating ? "Crear Producto" : "Editar Producto"}</h2>
          <button className="product-modal__close-btn" onClick={onClose} disabled={loading}>
            <X size={24} />
          </button>
        </div>

        <form onSubmit={handleSubmit} className="product-modal__form">
          <div className="product-modal__form-grid">
            <div className="product-modal__form-group">
              <label htmlFor="name" className="product-modal__label">
                Nombre *
              </label>
              <input
                type="text"
                id="name"
                name="name"
                value={formData.name}
                onChange={handleInputChange}
                className={`product-modal__input ${errors.name ? "error" : ""}`}
                disabled={loading}
              />
              {errors.name && <span className="product-modal__error">{errors.name}</span>}
            </div>

            <div className="product-modal__form-group">
              <label htmlFor="price" className="product-modal__label">
                Precio *
              </label>
              <input
                type="number"
                id="price"
                name="price"
                value={formData.price}
                onChange={handleInputChange}
                step="0.01"
                min="0"
                className={`product-modal__input ${errors.price ? "error" : ""}`}
                disabled={loading}
              />
              {errors.price && <span className="product-modal__error">{errors.price}</span>}
            </div>

            <div className="product-modal__form-group">
              <label htmlFor="stock" className="product-modal__label">
                Stock *
              </label>
              <input
                type="number"
                id="stock"
                name="stock"
                value={formData.stock}
                onChange={handleInputChange}
                min="0"
                className={`product-modal__input ${errors.stock ? "error" : ""}`}
                disabled={loading}
              />
              {errors.stock && <span className="product-modal__error">{errors.stock}</span>}
            </div>

            <div className="product-modal__form-group">
              <label htmlFor="categoryId" className="product-modal__label">
                Categoría *
              </label>
              <select
                id="categoryId"
                name="categoryId"
                value={formData.categoryId}
                onChange={handleInputChange}
                className={`product-modal__select ${errors.categoryId ? "error" : ""}`}
                disabled={loading}
              >
                <option value="">Seleccionar categoría</option>
                {categories.map((category) => (
                  <option key={category.CategoryId} value={category.CategoryId.toString()}>
                    {category.CategoryName}
                  </option>
                ))}
              </select>
              {errors.categoryId && <span className="product-modal__error">{errors.categoryId}</span>}
            </div>
          </div>

          <div className="product-modal__form-group">
            <label htmlFor="description" className="product-modal__label">
              Descripción *
            </label>
            <textarea
              id="description"
              name="description"
              value={formData.description}
              onChange={handleInputChange}
              className={`product-modal__textarea ${errors.description ? "error" : ""}`}
              rows={3}
              disabled={loading}
            />
            {errors.description && <span className="product-modal__error">{errors.description}</span>}
          </div>

          <div className="product-modal__form-group">
            <label htmlFor="image" className="product-modal__label">
              URL de Imagen
            </label>
            <input
              type="url"
              id="image"
              name="image"
              value={formData.image}
              onChange={handleInputChange}
              className="product-modal__input"
              placeholder="https://ejemplo.com/imagen.jpg"
              disabled={loading}
            />
          </div>

          {formData.image && (
            <div className="product-modal__image-preview">
              <img
                src={formData.image || "/placeholder.svg"}
                alt="Vista previa"
                className="product-modal__preview-image"
                onError={(e) => {
                  const target = e.target as HTMLImageElement
                  target.style.display = "none"
                }}
              />
            </div>
          )}

          <div className="product-modal__actions">
            <button type="button" onClick={onClose} className="product-modal__cancel-btn" disabled={loading}>
              Cancelar
            </button>
            <button type="submit" className="product-modal__save-btn" disabled={loading}>
              {loading ? <div className="product-modal__button-spinner"></div> : <Save size={20} />}
              {isCreating ? "Crear" : "Guardar"}
            </button>
          </div>
        </form>
      </div>
    </div>
  )
}

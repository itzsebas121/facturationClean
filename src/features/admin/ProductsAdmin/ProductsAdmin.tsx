"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { Edit, Plus, EyeOff, Search, Filter } from "lucide-react"
import "./ProductsAdmin.css"
import type { Product } from "../../../types/Product"
import {
  createProductService,
  inAvalibleProductService,
  updateProductService,
  getProductsService,
} from "../../../api/services/ProductService"
import { Pagination } from "../../../components/Pagination/Pagination"
import { ProductModal } from "./ProductModal"
import { adaptProduct } from "../../../adapters/ProductAdapter"

interface GetProductsParams {
  filtro?: string
  categoryId?: string
  page?: number
  pageSize?: number
}

interface ProductsResponse {
  products: any[]
  total: number
}

export function ProductsAdmin() {
  const [products, setProducts] = useState<Product[]>([])
  const [loading, setLoading] = useState(false)
  const [currentPage, setCurrentPage] = useState(1)
  const [totalPages, setTotalPages] = useState(1)
  const [totalProducts, setTotalProducts] = useState(0)
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("")
  const [isModalOpen, setIsModalOpen] = useState(false)
  const [selectedProduct, setSelectedProduct] = useState<Product | null>(null)
  const [isCreating, setIsCreating] = useState(false)
  const [actionLoading, setActionLoading] = useState<string | null>(null)

  const pageSize = 10

  useEffect(() => {
    fetchProducts()
  }, [currentPage, searchTerm, selectedCategory])

  const fetchProducts = async () => {
    setLoading(true)
    try {
      const params: GetProductsParams = {
        page: currentPage,
        pageSize: pageSize,
      }

      if (searchTerm.trim()) {
        params.filtro = searchTerm.trim()
      }

      if (selectedCategory) {
        params.categoryId = selectedCategory
      }

      const response: ProductsResponse = await getProductsService(params)

      // Adapt products using the adapter
      const adaptedProducts = response.products.map(adaptProduct)

      setProducts(adaptedProducts)
      setTotalProducts(response.total)
      setTotalPages(Math.ceil(response.total / pageSize))
    } catch (error) {
      console.error("Error fetching products:", error)
    } finally {
      setLoading(false)
    }
  }

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    setCurrentPage(1)
    fetchProducts()
  }

  const handleCreateProduct = () => {
    setSelectedProduct(null)
    setIsCreating(true)
    setIsModalOpen(true)
  }

  const handleEditProduct = (product: Product) => {
    setSelectedProduct(product)
    setIsCreating(false)
    setIsModalOpen(true)
  }

  const handleToggleAvailability = async (product: Product) => {
    setActionLoading(product.id.toString())
    try {
      await inAvalibleProductService(product.id)
      await fetchProducts()
    } catch (error) {
      console.error("Error toggling product availability:", error)
    } finally {
      setActionLoading(null)
    }
  }

  const handleSaveProduct = async (productData: Omit<Product, "id"> | Product) => {
    setActionLoading("modal")
    try {
      if (isCreating) {
        await createProductService(productData as Product)
      } else {
        await updateProductService(productData as Product)
      }
      setIsModalOpen(false)
      await fetchProducts()
    } catch (error) {
      console.error("Error saving product:", error)
    } finally {
      setActionLoading(null)
    }
  }

  const handlePageChange = (page: number) => {
    setCurrentPage(page)
  }

  const formatPrice = (price: number) => {
    return new Intl.NumberFormat("es-ES", {
      style: "currency",
      currency: "USD",
    }).format(price)
  }

  return (
    <div className="products-admin">
      <div className="products-admin__header">
        <h1 className="products-admin__title">Gestión de Productos</h1>
        <button className="products-admin__create-btn" onClick={handleCreateProduct} disabled={loading}>
          <Plus size={20} />
          Crear Producto
        </button>
      </div>

      <div className="products-admin__filters">
        <form onSubmit={handleSearch} className="products-admin__search-form">
          <div className="products-admin__search-input-wrapper">
            <Search className="products-admin__search-icon" size={20} />
            <input
              type="text"
              placeholder="Buscar productos..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="products-admin__search-input"
            />
          </div>
          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="products-admin__category-select"
          >
            <option value="">Todas las categorías</option>
            <option value="1">Electrónica</option>
            <option value="2">Ropa</option>
            <option value="3">Alimentos</option>
            <option value="4">Hogar</option>
          </select>
          <button type="submit" className="products-admin__search-btn" disabled={loading}>
            <Filter size={20} />
            Filtrar
          </button>
        </form>
      </div>

      <div className="products-admin__stats">
        <p className="products-admin__stats-text">
          Total de productos: <span className="products-admin__stats-number">{totalProducts}</span>
        </p>
      </div>

      {loading ? (
        <div className="products-admin__loading">
          <div className="products-admin__spinner"></div>
          <p>Cargando productos...</p>
        </div>
      ) : (
        <>
          <div className="products-admin__grid">
            {products.map((product) => (
              <div key={product.id} className="products-admin__card">
                <div className="products-admin__card-image">
                  <img
                    src={product.image || "/placeholder.svg?height=150&width=150"}
                    alt={product.name}
                    className="products-admin__image"
                    onError={(e) => {
                      const target = e.target as HTMLImageElement
                      target.src = "/placeholder.svg?height=150&width=150"
                    }}
                  />
                </div>

                <div className="products-admin__card-content">
                  <div className="products-admin__card-header">
                    <h3 className="products-admin__card-title">{product.name}</h3>
                    <div className="products-admin__price">{formatPrice(product.price)}</div>
                  </div>

                  <div className="products-admin__card-info">
                    <p className="products-admin__description">{product.description}</p>
                    <div className="products-admin__details">
                      <p>
                        <strong>Categoría:</strong> {product.category}
                      </p>
                      <p>
                        <strong>Stock:</strong> {product.stock}
                      </p>
                    </div>
                  </div>
                </div>

                <div className="products-admin__card-actions">
                  <button
                    className="products-admin__edit-btn"
                    onClick={() => handleEditProduct(product)}
                    disabled={actionLoading === product.id.toString()}
                  >
                    <Edit size={16} />
                    Editar
                  </button>
                  <button
                    className="products-admin__toggle-btn"
                    onClick={() => handleToggleAvailability(product)}
                    disabled={actionLoading === product.id.toString()}
                  >
                    {actionLoading === product.id.toString() ? (
                      <div className="products-admin__button-spinner"></div>
                    ) : (
                      <EyeOff size={16} />
                    )}
                    Inhabilitar
                  </button>
                </div>
              </div>
            ))}
          </div>

          {products.length === 0 && !loading && (
            <div className="products-admin__empty">
              <p>No se encontraron productos</p>
            </div>
          )}

          {totalPages > 1 && (
            <div className="products-admin__pagination">
              <Pagination currentPage={currentPage} totalPages={totalPages} onPageChange={handlePageChange} />
            </div>
          )}
        </>
      )}

      {isModalOpen && (
        <ProductModal
          product={selectedProduct}
          isOpen={isModalOpen}
          onClose={() => setIsModalOpen(false)}
          onSave={handleSaveProduct}
          isCreating={isCreating}
          loading={actionLoading === "modal"}
        />
      )}
    </div>
  )
}

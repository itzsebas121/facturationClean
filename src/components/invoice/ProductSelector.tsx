import { useState, useEffect } from "react"
import type { Product } from "../../types/Product"
import type { Category } from "../../types/Categorie"
import { getProductsService } from "../../api/services/ProductService"
import { getCategoriesService } from "../../api/services/CategoryService"
import { adaptProduct } from "../../adapters/ProductAdapter"
import { adaptCategorie } from "../../adapters/CategorieAdapter"
import { Search, X } from "lucide-react"
import "./ProductSelector.css"
import { Pagination } from "../Pagination/Pagination"
import ProductCard from "./ProductCard"

interface ProductSelectorProps {
  onSelect: (product: Product, quantity: number) => void
  onClose: () => void
}

export default function ProductSelector({ onSelect, onClose }: ProductSelectorProps) {
  const [products, setProducts] = useState<Product[]>([])
  const [categories, setCategories] = useState<Category[]>([])
  const [loading, setLoading] = useState(false)
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("")
  const [currentPage, setCurrentPage] = useState(1)
  const [totalProducts, setTotalProducts] = useState(0)
  const [quantities, setQuantities] = useState<{ [key: string]: number }>({})

  const pageSize = 50
  const totalPages = Math.ceil(totalProducts / pageSize)

  useEffect(() => {
    fetchCategories()
    fetchProducts(1, "", "")
  }, [])

  useEffect(() => {
    setCurrentPage(1)
    fetchProducts(1, searchTerm, selectedCategory)
  }, [searchTerm, selectedCategory])

  const fetchProducts = async (page = 1, filtro = "", categoryId = "") => {
    setLoading(true)
    try {
      const result = await getProductsService({
        filtro,
        categoryId,
        page,
        pageSize,
      })

      setProducts(result.products?.map((product: any) => adaptProduct(product)) || [])
      setTotalProducts(result.total || 0)
    } catch (error) {
      console.error("Error fetching products:", error)
      setProducts([])
    } finally {
      setLoading(false)
    }
  }

  const fetchCategories = async () => {
    try {
      const result = await getCategoriesService()
      const adaptedCategories = result.map((category: any) => adaptCategorie(category))
      setCategories(adaptedCategories)
    } catch (error) {
      console.error("Error fetching categories:", error)
    }
  }

  const handlePageChange = (page: number) => {
    setCurrentPage(page)
    fetchProducts(page, searchTerm, selectedCategory)
  }

  const updateQuantity = (productId: string, quantity: number) => {
    if (quantity < 1) quantity = 1
    setQuantities((prev) => ({ ...prev, [productId]: quantity }))
  }

  const getQuantity = (productId: string) => {
    return quantities[productId] || 1
  }

  const handleAddProduct = (product: Product) => {
    const quantity = getQuantity(String(product.id))
    onSelect(product, quantity)
  }

  return (
    <div className="modal-overlay">
      <div className="product-selector-modal">
        <div className="modal-header">
          <h2>Seleccionar Productos</h2>
          <button className="close-btn" onClick={onClose}>
            <X size={24} />
          </button>
        </div>

        <div className="search-section">
          <div className="search-input-container">
            <Search className="search-icon" size={20} />
            <input
              type="text"
              placeholder="Buscar productos..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="search-input"
            />
          </div>

          <select
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
            className="filter-select"
          >
            <option value="">Todas las categorías</option>
            {categories.map((category) => (
              <option key={category.id} value={category.id}>
                {category.name}
              </option>
            ))}
          </select>
        </div>

        <div className="products-info">
          <span className="products-count">
            {loading
              ? "Buscando..."
              : `${totalProducts} producto${totalProducts !== 1 ? "s" : ""} encontrado${totalProducts !== 1 ? "s" : ""}`}
          </span>
          {totalPages > 1 && (
            <span className="page-info">
              Página {currentPage} de {totalPages}
            </span>
          )}
        </div>

        <div className="products-list">
          {loading ? (
            <div className="loading-products">
              <p>Cargando productos...</p>
            </div>
          ) : products.length === 0 ? (
            <div className="no-results">
              <p>No se encontraron productos</p>
            </div>
          ) : (
            <div className="products-grid">
              {products.map((product) => (
                <ProductCard
                  key={product.id}
                  product={product}
                  quantity={getQuantity(String(product.id))}
                  onQuantityChange={(quantity) => updateQuantity(String(product.id), quantity)}
                  onAddToInvoice={() => handleAddProduct(product)}
                />
              ))}
            </div>
          )}
        </div>

        {totalPages > 1 && (
          <div className="pagination-container">
            <Pagination currentPage={currentPage} totalPages={totalPages} onPageChange={handlePageChange} />
          </div>
        )}
      </div>
    </div>
  )
}

"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { Edit, Plus, EyeOff, Search, Filter, RotateCcw } from "lucide-react"
import "./ProductsAdmin.css"
import type { Product, GetProductsParams } from "../../../types/Product"
import {
  createProductService,
  updateProductService,
  getProductsService,
  disableProductService,
} from "../../../api/services/ProductService"
import { getCategoriesService } from "../../../api/services/CategoryService"
import { Pagination } from "../../../components/Pagination/Pagination"
import { ProductModal } from "./ProductModal"
import { adaptProduct } from "../../../adapters/ProductAdapter"
import { Alert } from "../../../components/UI/Alert"
import { ConfirmDialog } from "../../../components/UI/ConfirmDialog"

interface Category {
  CategoryId: number
  CategoryName: string
}

interface AlertState {
  show: boolean
  type: "success" | "error" | "info" | "warning"
  message: string
}

interface ConfirmState {
  show: boolean
  title: string
  message: string
  onConfirm: () => void
}

export function ProductsAdmin() {
  const [products, setProducts] = useState<Product[]>([])
  const [categories, setCategories] = useState<Category[]>([])
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
  const [alert, setAlert] = useState<AlertState>({ show: false, type: "info", message: "" })
  const [confirm, setConfirm] = useState<ConfirmState>({ show: false, title: "", message: "", onConfirm: () => { } })
  const [imageLoadStates, setImageLoadStates] = useState<Record<string, "loading" | "loaded" | "error">>({})

  const pageSize = 50 // Increased for more compact view

  useEffect(() => {
    fetchCategories()
    fetchProducts()
  }, [currentPage, searchTerm, selectedCategory])

  const showAlert = (type: AlertState["type"], message: string) => {
    setAlert({ show: true, type, message })
  }

  const hideAlert = () => {
    setAlert({ show: false, type: "info", message: "" })
  }

  const showConfirm = (title: string, message: string, onConfirm: () => void) => {
    setConfirm({ show: true, title, message, onConfirm })
  }

  const hideConfirm = () => {
    setConfirm({ show: false, title: "", message: "", onConfirm: () => { } })
  }

  const fetchCategories = async () => {
    try {
      const response = await getCategoriesService()
      if (response.error) {
        showAlert("error", response.error)
      } else {
        setCategories(response)
      }
    } catch (error) {
      showAlert("error", "Error al cargar las categorías")
    }
  }

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

      const response = await getProductsService(params)

      if ("error" in response) {
        showAlert("error", response.error as string)
      } else {
        const adaptedProducts = response.products.map(adaptProduct)
        setProducts(adaptedProducts)
        setTotalProducts(response.total)
        setTotalPages(Math.ceil(response.total / pageSize))
      }
    } catch (error) {
      showAlert("error", "Error al cargar los productos")
    } finally {
      setLoading(false)
    }
  }

  const handleSearch = (e: React.FormEvent) => {
    e.preventDefault()
    setCurrentPage(1)
    fetchProducts()
  }

  const handleClearFilters = () => {
    setSearchTerm("")
    setSelectedCategory("")
    setCurrentPage(1)
    // Trigger fetch with cleared filters
    setTimeout(() => {
      fetchProducts()
    }, 0)
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

  const handleToggleAvailability = (product: Product) => {
    showConfirm("Confirmar acción", `¿Estás seguro de que deseas inhabilitar el producto "${product.name}"?`, () =>
      confirmToggleAvailability(product),
    )
  }

  const confirmToggleAvailability = async (product: Product) => {
    setActionLoading(product.id.toString())
    try {
      const response = await disableProductService(product.id)
      if (response.error || response.Error) {
        showAlert("error", response.error || response.Error || "Error al inhabilitar el producto")
      } else {
        showAlert("success", "Producto inhabilitado correctamente")
        await fetchProducts()
      }
    } catch (error) {
      showAlert("error", "Error al inhabilitar el producto")
    } finally {
      setActionLoading(null)
      hideConfirm()
    }
  }

  const handleSaveProduct = async (productData: any) => {
    setActionLoading("modal")
    try {
      let response
      if (isCreating) {
        const createData = {
          CategoryId: Number.parseInt(productData.categoryId),
          Name: productData.name,
          Description: productData.description,
          Price: Number.parseFloat(productData.price),
          Stock: Number.parseInt(productData.stock),
          ImageUrl: productData.image || "",
        }
        response = await createProductService(createData as any)
      } else {
        const updateData = {
          ProductId: selectedProduct!.id,
          CategoryId: Number.parseInt(productData.categoryId),
          Name: productData.name,
          Description: productData.description,
          Price: Number.parseFloat(productData.price),
          Stock: Number.parseInt(productData.stock),
          ImageUrl: productData.image || "",
        }
        response = await updateProductService(updateData as any)
      }

      if (response.error || response.Error) {
        showAlert("error", response.error || response.Error || "Error al crear el producto")
      } else {
        showAlert("success", isCreating ? "Producto creado correctamente" : "Producto actualizado correctamente")
        setIsModalOpen(false)
        await fetchProducts()
      }
    } catch (error) {
      showAlert("error", `Error al ${isCreating ? "crear" : "actualizar"} el producto`)
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

  const handleImageLoad = (productId: string) => {
    setImageLoadStates((prev) => ({ ...prev, [productId]: "loaded" }))
  }

  const handleImageError = (productId: string) => {
    setImageLoadStates((prev) => ({ ...prev, [productId]: "error" }))
  }

  const getImageState = (productId: string) => {
    return imageLoadStates[productId] || "loading"
  }

  const getProductInitial = (name: string) => {
    return name.charAt(0).toUpperCase()
  }

  const getStockStatus = (stock: number) => {
    if (stock === 0) return "out-of-stock"
    if (stock < 10) return "low-stock"
    return "in-stock"
  }

  const getStockText = (stock: number) => {
    if (stock === 0) return "Sin stock"
    if (stock < 10) return `Bajo stock (${stock})`
    return `En stock (${stock})`
  }

  const hasActiveFilters = searchTerm.trim() !== "" || selectedCategory !== ""

  return (
    <div className="products-admin">
      {alert.show && <Alert type={alert.type} message={alert.message} onClose={hideAlert} />}

      <ConfirmDialog
        isOpen={confirm.show}
        title={confirm.title}
        message={confirm.message}
        onConfirm={confirm.onConfirm}
        onCancel={hideConfirm}
        type="danger"
        confirmText="Inhabilitar"
      />

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
            {categories.map((category) => (
              <option key={category.CategoryId} value={category.CategoryId.toString()}>
                {category.CategoryName}
              </option>
            ))}
          </select>
          <button type="submit" className="products-admin__search-btn" disabled={loading}>
            <Filter size={20} />
            Filtrar
          </button>
          {hasActiveFilters && (
            <button type="button" className="products-admin__clear-btn" onClick={handleClearFilters} disabled={loading}>
              <RotateCcw size={20} />
              Limpiar
            </button>
          )}
        </form>
      </div>

      <div className="products-admin__stats">
        <p className="products-admin__stats-text">
          Total de productos: <span className="products-admin__stats-number">{totalProducts}</span>
          {hasActiveFilters && <span className="products-admin__filter-indicator">(filtrado)</span>}
        </p>
      </div>

      {loading ? (
        <div className="products-admin__loading">
          <div className="products-admin__spinner"></div>
          <p>Cargando productos...</p>
        </div>
      ) : (
        <>
          <div className="products-admin__list">
            {products.map((product) => (
              <div key={product.id} className="product-item">
                <div className="product-item__image-container">
                  {product.image ? (
                    <>
                      {getImageState(product.id.toString()) === "loading" && (
                        <div className="image-loading">
                          <div className="loading-icon">
                            <div className="products-admin__spinner"></div>
                          </div>
                        </div>
                      )}
                      {getImageState(product.id.toString()) === "error" && (
                        <div className="image-error">
                          <div className="product-initial">{getProductInitial(product.name)}</div>
                        </div>
                      )}
                      <img
                        src={product.image || "/placeholder.svg"}
                        alt={product.name}
                        className={`product-item__image ${getImageState(product.id.toString()) === "loaded" ? "loaded" : ""}`}
                        onLoad={() => handleImageLoad(product.id.toString())}
                        onError={() => handleImageError(product.id.toString())}
                        style={{ display: getImageState(product.id.toString()) === "loaded" ? "block" : "none" }}
                      />
                    </>
                  ) : (
                    <div className="image-error">
                      <div className="product-initial">{getProductInitial(product.name)}</div>
                    </div>
                  )}
                </div>

                <div className="product-item__main">
                  <h3 className="product-item__name">{product.name}</h3>
                  <span className="product-item__category">{product.category}</span>
                  <p className="product-item__description">{product.description}</p>
                </div>
                <div className="product-item__content">

                  <div className="product-item__details">
                    <div className="product-item__price">{formatPrice(product.price)}</div>
                    <div className={`product-item__stock ${getStockStatus(product.stock || 0)}`}>
                      <div className="stock-dot"></div>
                      <span className="stock-text">{getStockText(product.stock || 0)}</span>
                    </div>
                  </div>
                </div>

                <div className="product-item__actions">
                  <button
                    className="product-item__edit-btn"
                    onClick={() => handleEditProduct(product)}
                    disabled={actionLoading === product.id.toString()}
                    title="Editar producto"
                  >
                    <Edit size={16} />
                  </button>
                  <button
                    className="product-item__disable-btn"
                    onClick={() => handleToggleAvailability(product)}
                    disabled={actionLoading === product.id.toString()}
                    title="Inhabilitar producto"
                  >
                    {actionLoading === product.id.toString() ? (
                      <div className="products-admin__button-spinner"></div>
                    ) : (
                      <EyeOff size={16} />
                    )}
                  </button>
                </div>
              </div>
            ))}
          </div>

          {products.length === 0 && !loading && (
            <div className="products-admin__empty">
              <p>No se encontraron productos</p>
              {hasActiveFilters && (
                <button className="products-admin__clear-empty-btn" onClick={handleClearFilters}>
                  <RotateCcw size={16} />
                  Limpiar filtros
                </button>
              )}
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
          categories={categories}
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

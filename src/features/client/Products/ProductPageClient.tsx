"use client"

import { useEffect, useState } from "react"
import { getProductsService } from "../../../api/services/ProductService"
import { adaptProduct } from "../../../adapters/ProductAdapter"
import type { Product } from "../../../types/Product"
import { getCategoriesService } from "../../../api/services/CategoryService"
import type { Category } from "../../../types/Categorie"
import { adaptCategorie } from "../../../adapters/CategorieAdapter"
import { SearchFilters } from "./SearchFilters"
import { ProductGrid } from "../../../components/Products/ProductGrid"
import { Pagination } from "../../../components/Pagination/Pagination"
import { Loader2 } from "lucide-react"
import "./ProductPage.css"

export function ProductPageClient() {
  const [products, setProducts] = useState<Product[]>([])
  const [categories, setCategories] = useState<Category[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedCategory, setSelectedCategory] = useState("")
  const [currentPage, setCurrentPage] = useState(1)
  const [totalProducts, setTotalProducts] = useState(0)
  const [productsLoading, setProductsLoading] = useState(false)

  const pageSize = 50
  const totalPages = Math.ceil(totalProducts / pageSize)

  const fetchProducts = async (page = 1, filtro = "", categoryId = "") => {
    setProductsLoading(true)
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
      setProductsLoading(false)
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

  useEffect(() => {
    const loadInitialData = async () => {
      setLoading(true)
      await Promise.all([fetchCategories(), fetchProducts(1, searchTerm, selectedCategory)])
      setLoading(false)
    }

    loadInitialData()
  }, [])

  useEffect(() => {
    if (!loading) {
      setCurrentPage(1)
      fetchProducts(1, searchTerm, selectedCategory)
    }
  }, [searchTerm, selectedCategory])

  const handlePageChange = (page: number) => {
    setCurrentPage(page)
    fetchProducts(page, searchTerm, selectedCategory)
    window.scrollTo({ top: 0, behavior: "smooth" })
  }

  const handleSearch = (term: string) => {
    setSearchTerm(term)
  }

  const handleCategoryChange = (categoryId: string) => {
    setSelectedCategory(categoryId)
  }

  if (loading) {
    return (
      <div className="loading-container">
        <Loader2 className="loading-spinner" />
        <p className="loading-text">Cargando productos...</p>
      </div>
    )
  }

  return (
    <div className="product-page">
      <header className="product-page-header">
        <h1 className="page-title">Catálogo de Productos</h1>
        <p className="page-subtitle">Descubre nuestra amplia selección de productos de calidad</p>
      </header>

      <SearchFilters
        categories={categories}
        onSearch={handleSearch}
        onCategoryChange={handleCategoryChange}
        searchTerm={searchTerm}
        selectedCategory={selectedCategory}
      />

      <div className="products-summary">
        <div className="products-info">
          <span className="products-count">
            {productsLoading
              ? "Buscando..."
              : `${totalProducts} producto${totalProducts !== 1 ? "s" : ""} encontrado${totalProducts !== 1 ? "s" : ""}`}
          </span>
          {totalPages > 1 && (
            <span className="page-info">
              Página {currentPage} de {totalPages}
            </span>
          )}
        </div>
      </div>

      <ProductGrid products={products} loading={productsLoading} />

      {totalPages > 1 && (
        <Pagination currentPage={currentPage} totalPages={totalPages} onPageChange={handlePageChange} />
      )}
    </div>
  )
}

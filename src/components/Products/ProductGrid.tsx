import type { Product } from "../../types/Product"
import { ProductCard } from "./ProductCard"
import { Package, Search } from "lucide-react"
import "./ProductGrid.css"

interface ProductGridProps {
  products: Product[]
  loading: boolean
}

export function ProductGrid({ products, loading }: ProductGridProps) {
  if (loading) {
    return (
      <div className="product-grid">
        {Array.from({ length: 12 }).map((_, index) => (
          <div key={index} className="product-card-skeleton">
            <div className="skeleton-image">
              <div className="skeleton-shimmer"></div>
            </div>
            <div className="skeleton-content">
              <div className="skeleton-title">
                <div className="skeleton-shimmer"></div>
              </div>
              <div className="skeleton-description">
                <div className="skeleton-shimmer"></div>
              </div>
              <div className="skeleton-price">
                <div className="skeleton-shimmer"></div>
              </div>
            </div>
          </div>
        ))}
      </div>
    )
  }

  if (products.length === 0) {
    return (
      <div className="no-products">
        <div className="no-products-icon">
          <Package size={48} />
          <Search size={24} className="search-overlay" />
        </div>
        <h3 className="no-products-title">No se encontraron productos</h3>
        <p className="no-products-message">Intenta ajustar tus filtros de búsqueda o explora otras categorías</p>
      </div>
    )
  }

  return (
    <div className="product-grid">
      {products.map((product) => (
        <ProductCard key={product.id} product={product} />
      ))}
    </div>
  )
}

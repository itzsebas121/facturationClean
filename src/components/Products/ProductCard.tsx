"use client"

import { useState } from "react"
import type { Product } from "../../types/Product"
import { Loader2, ImageOff, Folder } from "lucide-react"
import "./ProductCard.css"

interface ProductCardProps {
  product: Product
}

export function ProductCard({ product }: ProductCardProps) {
  const [imageLoaded, setImageLoaded] = useState(false)
  const [imageError, setImageError] = useState(false)

  const handleImageLoad = () => {
    setImageLoaded(true)
  }

  const handleImageError = () => {
    setImageError(true)
    setImageLoaded(true)
  }

  const getStockStatus = () => {
    if (product.stock === undefined) return null
    if (product.stock === 0) return "out-of-stock"
    if (product.stock <= 5) return "low-stock"
    return "in-stock"
  }

  const getStockMessage = () => {
    if (product.stock === undefined) return null
    if (product.stock === 0) return "Sin stock"
    if (product.stock <= 5) return `${product.stock} disponibles`
    return `${product.stock} disponibles`
  }

  return (
    <article className="product-card">
      <div className="product-image-container">
        {!imageLoaded && !imageError && (
          <div className="image-loading">
            <Loader2 className="loading-icon" />
          </div>
        )}

        {imageError ? (
          <div className="image-error">
            <ImageOff size={32} />
            <span>Imagen no disponible</span>
          </div>
        ) : (
          <img
            src={product.image || "/placeholder.svg?height=200&width=280"}
            alt={product.name}
            className={`product-image ${imageLoaded ? "loaded" : ""}`}
            onLoad={handleImageLoad}
            onError={handleImageError}
            loading="lazy"
          />
        )}

        {product.stock !== undefined && <div className={`stock-badge ${getStockStatus()}`}>{getStockMessage()}</div>}
      </div>

      <div className="product-content">
        <header className="product-header">
          <h3 className="product-name" title={product.name}>
            {product.name}
          </h3>
          {product.category && (
            <span className="product-category">
              <Folder size={14} />
              {product.category}
            </span>
          )}
        </header>

        <p className="product-description" title={product.description}>
          {product.description}
        </p>

        <footer className="product-footer">
          <div className="price-container">
            <span className="product-price">
              $
              {product.price.toLocaleString("es-ES", {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2,
              })}
            </span>
          </div>

          {product.stock !== undefined && (
            <div className="stock-info">
              <div className={`stock-indicator ${getStockStatus()}`}>
                <span className="stock-dot"></span>
                <span className="stock-text">{getStockMessage()}</span>
              </div>
            </div>
          )}
        </footer>
      </div>
    </article>
  )
}

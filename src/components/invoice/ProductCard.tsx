import { useState } from "react"
import type { Product } from "../../types/Product"
import { DollarSign, Hash, Plus, Minus, ShoppingCart } from "lucide-react"
import "./ProductCard.css"

interface ProductCardProps {
  product: Product
  quantity: number
  onQuantityChange: (quantity: number) => void
  onAddToInvoice: () => void
}

export default function ProductCard({ product, quantity, onQuantityChange, onAddToInvoice }: ProductCardProps) {
  const [showImagePreview, setShowImagePreview] = useState(false)

  const handleQuantityChange = (newQuantity: number) => {
    if (newQuantity >= 1 && newQuantity <= (product.stock ?? 0)) {
      onQuantityChange(newQuantity)
    }
  }

  return (
    <div className="product-card-enhanced">

      <div
        className={`stock-badge ${product.stock === 0 ? "out-of-stock" : (product.stock ?? 0) < 10 ? "low-stock" : "in-stock"}`}
      >
        {product.stock === 0 ? "Sin Stock" : `${product.stock} disponibles`}
      </div>

      <div className="product-info-enhanced">
        <h4 className="product-name">{product.name}</h4>

        {product.description && <p className="product-description">{product.description}</p>}

        <div className="product-details">
          <div className="price-section">
            <DollarSign size={16} />
            <span className="price">${product.price.toFixed(2)}</span>
          </div>

          <div className="category-section">
            <Hash size={16} />
            <span className="category">{product.category || "Sin categoría"}</span>
          </div>
        </div>
      </div>
      
        <button className="add-to-invoice-btn" onClick={onAddToInvoice} disabled={product.stock === 0}>
          <ShoppingCart size={16} />
          {product.stock === 0 ? "Sin Stock" : "Agregar"}
        </button>
    </div>
  )
}

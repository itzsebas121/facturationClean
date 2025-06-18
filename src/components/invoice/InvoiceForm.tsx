"use client"

import type { InvoiceData } from "./InvoiceManager"
import { Trash2, Minus, Plus, FileText, Loader2 } from "lucide-react"
import "./InvoiceForm.css"

interface InvoiceFormProps {
    invoiceData: InvoiceData
    onUpdateQuantity: (productId: string, quantity: number) => void
    onRemoveItem: (productId: string) => void
    onCreateOrder: () => void
    loading: boolean
}

export default function InvoiceForm({
    invoiceData,
    onUpdateQuantity,
    onRemoveItem,
    onCreateOrder,
    loading,
}: InvoiceFormProps) {
    const handleQuantityChange = (productId: string, newQuantity: number) => {
        if (newQuantity >= 1) {
            onUpdateQuantity(productId, newQuantity)
        }
    }

    return (
        <div className="invoice-form">
            <div className="invoice-summary">
                <h3>Resumen de Factura</h3>


            </div>

            <div className="invoice-items">
                <h4>Productos ({invoiceData.items.length})</h4>

                {invoiceData.items.length === 0 ? (
                    <div className="no-items">
                        <FileText size={48} />
                        <p>No hay productos en la factura</p>
                        <p>Selecciona productos para comenzar</p>
                    </div>
                ) : (
                    <div className="items-list">
                        {invoiceData.items.map((item) => (
                            <div key={item.product.id} className="invoice-item">
                                <div className="item-info">
                                    <h5>{item.product.name}</h5>
                                    <p className="item-price">${item.product.price.toFixed(2)} c/u</p>
                                    <p className="item-stock">Stock disponible: {item.product.stock}</p>
                                </div>

                                <div className="item-controls">
                                    <div className="quantity-section">
                                        <div className="item-stock">Cantidad</div>
                                        <div className="quantity-controls">
                                            <button
                                                className="quantity-btn"
                                                onClick={() => handleQuantityChange(String(item.product.id), item.quantity - 1)}
                                                disabled={item.quantity <= 1}
                                            >
                                                <Minus size={16} />
                                            </button>

                                            <input
                                                type="number"
                                                min="1"
                                                max={item.product.stock ?? 1}
                                                value={item.quantity}
                                                onChange={(e) => {
                                                    const value = Number.parseInt(e.target.value) || 1
                                                    handleQuantityChange(
                                                        String(item.product.id),
                                                        Math.min(value, item.product.stock ?? 1)
                                                    )
                                                }}
                                                className="quantity-input"
                                            />

                                            <button
                                                className="quantity-btn"
                                                onClick={() => handleQuantityChange(String(item.product.id), item.quantity + 1)}
                                                disabled={item.product.stock !== undefined ? item.quantity >= item.product.stock : false}
                                            >
                                                <Plus size={16} />
                                            </button>
                                        </div>
                                    </div>

                                </div>
                                <div className="item-subtotal">
                                    <div className="item-info">
                                        <p className="item-stock">Subtotal</p>

                                        <p className="item-price">${(item.product.price * item.quantity).toFixed(2)}</p>
                                    </div>

                                </div>
                                <button
                                    className="remove-btn"
                                    onClick={() => onRemoveItem(String(item.product.id))}
                                    title="Eliminar producto"
                                >
                                    <Trash2 size={16} />
                                </button>
                            </div>
                        ))}
                    </div>
                )}
            </div>

            <div className="invoice-total">
                <div className="total-section">
                    <div className="total-line">
                        <span>Subtotal:</span>
                        <span>${invoiceData.total.toFixed(2)}</span>
                    </div>
                    <div className="total-line">
                        <span>IVA (19%):</span>
                        <span>${(invoiceData.total * 0.19).toFixed(2)}</span>
                    </div>
                    <div className="total-line total-final">
                        <span>Total:</span>
                        <span>${(invoiceData.total * 1.19).toFixed(2)}</span>
                    </div>
                </div>

                <button
                    className="create-order-btn"
                    onClick={onCreateOrder}
                    disabled={!invoiceData.client || invoiceData.items.length === 0 || loading}
                >
                    {loading ? (
                        <>
                            <Loader2 className="loading-icon" size={20} />
                            Creando Orden...
                        </>
                    ) : (
                        "Crear Orden"
                    )}
                </button>
            </div>
        </div>
    )
}

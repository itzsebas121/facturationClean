import { Order } from "../../types/Order"
import { OrderDetail } from "../../types/OrderDetail"

export const generatePrintContent = (orderInfo: Order, details: OrderDetail[]) => {
    return `
          <!DOCTYPE html>
          <html>
            <head>
              <title>Factura ${orderInfo.orderId}</title>
              <style>
                body { 
                  font-family: 'Arial', sans-serif; 
                  margin: 0; 
                  padding: 20px; 
                  background-color: #f8f9fa;
                  color: #333;
                }
                .invoice-container {
                  max-width: 800px;
                  margin: 0 auto;
                  background: white;
                  padding: 40px;
                  border-radius: 8px;
                  box-shadow: 0 0 20px rgba(0,0,0,0.1);
                }
                .header { 
                  text-align: center; 
                  margin-bottom: 40px; 
                  border-bottom: 3px solid #2E3A2F;
                  padding-bottom: 20px;
                }
                .company-name {
                  font-size: 28px;
                  font-weight: bold;
                  color: #2E3A2F;
                  margin-bottom: 10px;
                }
                .invoice-title {
                  font-size: 24px;
                  color: #379d3a;
                  margin-bottom: 10px;
                }
                .invoice-number {
                  font-size: 18px;
                  color: #5F5F5F;
                }
                .customer-section {
                  margin-bottom: 30px;
                  padding: 20px;
                  background-color: #F5F7F4;
                  border-radius: 8px;
                }
                .section-title {
                  font-size: 18px;
                  font-weight: bold;
                  color: #2E3A2F;
                  margin-bottom: 15px;
                  border-bottom: 2px solid #379d3a;
                  padding-bottom: 5px;
                }
                .customer-info {
                  display: grid;
                  grid-template-columns: 1fr 1fr;
                  gap: 15px;
                }
                .info-item {
                  display: flex;
                  flex-direction: column;
                }
                .info-label {
                  font-weight: bold;
                  color: #5F5F5F;
                  font-size: 12px;
                  text-transform: uppercase;
                  margin-bottom: 5px;
                }
                .info-value {
                  color: #1C1C1C;
                  font-size: 14px;
                }
                .products-section {
                  margin: 30px 0;
                }
                .products-table {
                  width: 100%;
                  border-collapse: collapse;
                  margin-top: 15px;
                }
                .products-table th {
                  background-color: #2E3A2F;
                  color: white;
                  padding: 12px;
                  text-align: left;
                  font-weight: bold;
                }
                .products-table td {
                  padding: 12px;
                  border-bottom: 1px solid #ddd;
                }
                .products-table tr:nth-child(even) {
                  background-color: #f9f9f9;
                }
                .product-image {
                  width: 50px;
                  height: 50px;
                  object-fit: cover;
                  border-radius: 4px;
                }
                .product-name {
                  font-weight: 600;
                  color: #2E3A2F;
                }
                .price {
                  font-weight: 600;
                  color: #379d3a;
                }
                .financial-section {
                  margin-top: 40px;
                  padding: 20px;
                  background-color: #F5F7F4;
                  border-radius: 8px;
                }
                .financial-row {
                  display: flex;
                  justify-content: space-between;
                  margin-bottom: 10px;
                  padding: 8px 0;
                }
                .financial-label {
                  font-weight: 500;
                  color: #5F5F5F;
                }
                .financial-value {
                  font-weight: 600;
                  color: #1C1C1C;
                }
                .total-row {
                  border-top: 2px solid #379d3a;
                  margin-top: 15px;
                  padding-top: 15px;
                  font-size: 18px;
                  font-weight: bold;
                }
                .total-label {
                  color: #2E3A2F;
                }
                .total-value {
                  color: #379d3a;
                }
                .footer {
                  margin-top: 40px;
                  text-align: center;
                  color: #5F5F5F;
                  font-size: 12px;
                  border-top: 1px solid #DDE2DC;
                  padding-top: 20px;
                }
                @media print {
                  body { background-color: white; }
                  .invoice-container { box-shadow: none; }
                }
              </style>
            </head>
            <body>
              <div class="invoice-container">
                <div class="header">
                  <div class="company-name">Aplicaciones Móviles</div>
                  <div class="invoice-title">FACTURA</div>
                  <div class="invoice-number">Orden #${orderInfo.orderId}</div>
                </div>
                
                <div class="customer-section">
                  <div class="section-title">Información del Cliente</div>
                  <div class="customer-info">
                    <div class="info-item">
                      <div class="info-label">Nombre</div>
                      <div class="info-value">${orderInfo.customerName}</div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">Email</div>
                      <div class="info-value">${orderInfo.customerEmail}</div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">Teléfono</div>
                      <div class="info-value">${orderInfo.customerPhone}</div>
                    </div>
                    <div class="info-item">
                      <div class="info-label">Fecha</div>
                      <div class="info-value">${new Date(orderInfo.orderDate).toLocaleDateString("es-ES", {
        year: "numeric",
        month: "long",
        day: "numeric",
    })}</div>
                    </div>
                  </div>
                  <div style="margin-top: 15px;">
                    <div class="info-label">Dirección de Entrega</div>
                    <div class="info-value">${orderInfo.customerAddress}</div>
                  </div>
                </div>
                
                <div class="products-section">
                  <div class="section-title">Productos</div>
                  <table class="products-table">
                    <thead>
                      <tr>
                        <th>Imagen</th>
                        <th>Producto</th>
                        <th>Cantidad</th>
                        <th>Precio Unit.</th>
                        <th>Subtotal</th>
                      </tr>
                    </thead>
                    <tbody>
                      ${details
            .map(
                (item) => `
                        <tr>
                          <td><img src="${item.ImageUrl}" alt="${item.Name}" class="product-image" /></td>
                          <td class="product-name">${item.Name}</td>
                          <td>${item.Quantity}</td>
                          <td class="price">$${item.UnitPrice.toFixed(2)}</td>
                          <td class="price">$${item.SubTotal.toFixed(2)}</td>
                        </tr>
                      `,
            )
            .join("")}
                    </tbody>
                  </table>
                </div>
                
                <div class="financial-section">
                  <div class="section-title">Resumen Financiero</div>
                  <div class="financial-row">
                    <span class="financial-label">Subtotal:</span>
                    <span class="financial-value">$${orderInfo.orderSubtotal?.toFixed(2) || "0.00"}</span>
                  </div>
                  <div class="financial-row">
                    <span class="financial-label">Impuestos:</span>
                    <span class="financial-value">$${orderInfo.orderTax?.toFixed(2) || "0.00"}</span>
                  </div>
                  <div class="financial-row total-row">
                    <span class="total-label">TOTAL:</span>
                    <span class="total-value">$${orderInfo.orderTotal?.toFixed(2) || "0.00"}</span>
                  </div>
                </div>
                
                <div class="footer">
                  <p>Gracias por su compra</p>
                  <p>Factura generada el ${new Date().toLocaleDateString("es-ES")}</p>
                </div>
              </div>
            </body>
          </html>
        `
}
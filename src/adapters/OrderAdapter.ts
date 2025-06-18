import { Order } from "../types/Order";

export function adaptOrder(data: any): Order {
  return {
    orderId: data.OrderId ?? 0,
    customerId: data.Cedula ?? '',
    orderDate: new Date(data.OrderDate) ,
    customerName: data.Name ?? 'Sin Nombre',
    customerAddress: data.Address ?? 'Sin Dirección',
    customerEmail: data.Email ?? 'Sin Correo Electrónico',
    customerPhone: data.Phone ?? 'Sin Teléfono',
    orderSubtotal: data.SubTotal ?? 0,
    orderTax: data.Tax ?? 0,
    orderTotal: data.Total ?? 0,
  };
}
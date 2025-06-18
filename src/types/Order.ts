
export interface BaseOrder {
    orderId: number;
    customerId: string;
    orderDate: Date;
    customerName: string;
    customerAddress: string;
    customerEmail: string;
    customerPhone: string;
    orderSubtotal: number;
    orderTax: number;
    orderTotal: number;
}
export type Order = BaseOrder;
import { ORDER_ENDPOINTS } from "../endpoints/Orders";

export async function getOrdersService() {
    const res = await fetch(ORDER_ENDPOINTS.Orders, {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
    });
    if (!res.ok) {
        throw new Error('Failed to fetch clients');
    }
    return await res.json();
}
export async function createOrderService(order: any) {
    const res = await fetch(ORDER_ENDPOINTS.Orders, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(order),
    });
    if (!res.ok) {
        throw new Error('Failed to create order');
    }
    return await res.json();
}
export async function addDetailService(orderDetail: any) {
    const res = await fetch(ORDER_ENDPOINTS.AddDetail, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(orderDetail),
    });
    if (!res.ok) {
        throw new Error('Failed to add detail');
    }
    return await res.json();
}

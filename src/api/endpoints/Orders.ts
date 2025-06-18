import { API_BASE_URL } from "../config";
export const ORDER_ENDPOINTS = {
    Orders: `${API_BASE_URL}/api/orders`,
    OrderByClient: (clientId: string) => `${API_BASE_URL}/api/orders?clientId=${clientId}`,
    AddDetail: `${API_BASE_URL}/api/orders/addDetail`,
}
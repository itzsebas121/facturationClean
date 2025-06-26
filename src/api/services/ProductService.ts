import { PRODUCTS_ENDPOINTS } from "../endpoints/Products";
import { GetProductsParams } from "../../types/Product";


export async function getProductsService({ filtro, categoryId, page = 1, pageSize = 10 }: GetProductsParams, isAdmin = false) {
    const queryParams = new URLSearchParams();

    if (filtro) queryParams.append("filtro", filtro);
    if (categoryId) queryParams.append("categoryId", categoryId);
    queryParams.append("page", page.toString());
    queryParams.append("pageSize", pageSize.toString());
    if (isAdmin) queryParams.append("isAdmin", "true");

    const res = await fetch(`${PRODUCTS_ENDPOINTS.Product}?${queryParams.toString()}`, {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
    });

    if (!res.ok) {
        throw new Error('Failed to fetch products');
    }

    return await res.json();
}
export async function createProductService(product: any) {
    console.log(product);
    const res = await fetch(`${PRODUCTS_ENDPOINTS.Product}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(product),
    });

    return await res.json();
}
export async function updateProductService(product: any) {
    const res = await fetch(`${PRODUCTS_ENDPOINTS.Product}/${product.ProductId}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(product),
    });
    return await res.json();
}
export async function enableProductService(id: number) {
    const res = await fetch(`${PRODUCTS_ENDPOINTS.Product}/enable/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
    });
    return await res.json();
}
export async function disableProductService(id: number) {
    const res = await fetch(`${PRODUCTS_ENDPOINTS.Product}/disable/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
    });
    return await res.json();
}
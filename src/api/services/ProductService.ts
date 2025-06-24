import { PRODUCTS_ENDPOINTS } from "../endpoints/Products";
import { GetProductsParams, Product } from "../../types/Product";


export async function getProductsService({ filtro, categoryId, page = 1, pageSize = 10 }: GetProductsParams) {
    const queryParams = new URLSearchParams();

    if (filtro) queryParams.append("filtro", filtro);
    if (categoryId) queryParams.append("categoryId", categoryId);
    queryParams.append("page", page.toString());
    queryParams.append("pageSize", pageSize.toString());

    const res = await fetch(`${PRODUCTS_ENDPOINTS.Product}?${queryParams.toString()}`, {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
    });

    if (!res.ok) {
        throw new Error('Failed to fetch products');
    }

    return await res.json();
}
export async function createProductService(product: Product) {
    const res = await fetch(`${PRODUCTS_ENDPOINTS.Product}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(product),
    });
    return await res.json();
}
export async function updateProductService(product: Product) {
    const res = await fetch(`${PRODUCTS_ENDPOINTS.Product}/${product.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(product),
    });
    return await res.json();
}
export async function inAvalibleProductService(id: number) {
    const res = await fetch(`${PRODUCTS_ENDPOINTS.Product}/${id}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
    });
    return await res.json();
}
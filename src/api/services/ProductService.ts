import { PRODUCTS_ENDPOINTS } from "../endpoints/Products";
import { GetProductsParams } from "../../types/Product";


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

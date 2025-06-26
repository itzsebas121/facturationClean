export interface ProductBase {
    id: number;
    name: string;
    price: number;
    description: string;
    isActive: boolean;
    image: string;
    stock?: number;
    category?: string;
}
export interface GetProductsParams {
    filtro?: string;
    categoryId?: string;
    page?: number;
    pageSize?: number;
}
export type Product =  ProductBase;
import { ProductBase } from "../types/Product";
export function adaptProduct(data: any): ProductBase {
  return {
    id: data.ProductId ?? 0,
    name: data.Name ?? 'Sin Nombre',
    price: data.Price ?? 0,
    description: data.Description ?? 'Sin Descripción',
    image: data.ImageUrl ?? '',
    stock: data.Stock ?? 0,
    category: data.CategoryName ?? 'Sin Categoría',
  };
}
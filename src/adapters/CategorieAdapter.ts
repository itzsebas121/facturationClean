import { CategoryBase } from "../types/Categorie";
export function adaptCategorie(data: any): CategoryBase {
  return {
    id: data.CategoryId ?? 0,
    name: data.CategoryName ?? 'Sin Nombre',
    description: data.Description ?? 'Sin Descripción',
  };
}
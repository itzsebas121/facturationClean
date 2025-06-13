import { CATEGORIES_ENDPOINTS } from "../endpoints/Categories";

export async function getCategoriesService() {
    const res = await fetch(CATEGORIES_ENDPOINTS.Categories, {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
    });

    if (!res.ok) {
        throw new Error('Failed to fetch categories');
    }

    return await res.json();
}
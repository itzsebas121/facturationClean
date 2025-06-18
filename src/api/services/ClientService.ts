import { CLIENTS_ENDPOINTS } from "../endpoints/Clients";

export async function getClientsService() {
    const res = await fetch(CLIENTS_ENDPOINTS.Client, {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
    });
    if (!res.ok) {
        throw new Error('Failed to fetch clients');
    }
    return await res.json();
}
import { Client } from "../../types/User";
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

export async function createClientService(client: Client) {
    const res = await fetch(CLIENTS_ENDPOINTS.Client, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(client),
    });
    return await res.json();
}
export async function updateClientService(client: Client) {
    const res = await fetch(`${CLIENTS_ENDPOINTS.Client}/${client.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(client),
    });
    return await res.json();
}
export async function deleteClientService(id: number) {
    const res = await fetch(`${CLIENTS_ENDPOINTS.Client}/${id}`, {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
    });
    return await res.json();
}
export async function getClientsByUserIdService(userId: number) {
    const res = await fetch(`${CLIENTS_ENDPOINTS.Client}/${userId}`, {
        method: 'GET',
        headers: { 'Content-Type': 'application/json' },
    });
    if (!res.ok) {
        throw new Error('Failed to fetch clients');
    }
    return await res.json();
}

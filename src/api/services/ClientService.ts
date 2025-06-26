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
export async function createClientService(client: any) {
    const res = await fetch(CLIENTS_ENDPOINTS.Client, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(client),
    });
    return await res.json();
}
export async function updateClientService(client: any) {
    const clientPost = {
        clientId: client.clientId,
        firstName: client.primerNombre,
        lastName: client.primerApellido,
        email: client.email,
        phone: client.telefono,
        address: client.direccion,
        cedula: client.cedula
    };
    const res = await fetch(`${CLIENTS_ENDPOINTS.Client}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(clientPost),
    });
    return await res.json();
}
export async function enableClientService(id: number) {
    const res = await fetch(`${CLIENTS_ENDPOINTS.Client}/enable/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
    });
    return await res.json();
}
export async function disableClientService(id: number) {
    const res = await fetch(`${CLIENTS_ENDPOINTS.Client}/disable/${id}`, {
        method: 'PUT',
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
export async function changePasswordService(userId: number, currentPassword: string, newPassword: string) {

    const res = await fetch(`${CLIENTS_ENDPOINTS.Client}/changePassword`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ userId: userId, currentPassword: currentPassword, newPassword: newPassword }),
    });
    
    return await res.json();
}
import { USER_ENDPOINTS } from '../endpoints/user';

export async function loginService(credentials: { email: string; password: string }) {
    const res = await fetch(USER_ENDPOINTS.LOGIN, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials),
    });
    return await res.json(); 
}


import type { Admin, Client } from '../types/User';

export type User = Admin  | Client;

export function adaptarUsuario(data: any): User {
  const base = {
    id: data.userId ?? data.id ?? '',
    nombre: data.nombre ?? 'Sin nombre',
    rol: data.rol ?? 'cliente',
  };

  switch (base.rol) {
    case 'Admin':
      return {
        ...base,
        rol: 'Admin',
        email: data.email ?? '',
      } as Admin;

    case 'Client':
    default:
      return {
        ...base,
        rol: 'Client',
        email: data.email ?? '',
        direccion: data.direccion ?? 'Sin dirección',
      } as Client;
  }
}

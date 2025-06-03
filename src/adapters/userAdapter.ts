
import type { Admin, Client } from '../types/User';

export type User = Admin  | Client;

export function adaptarUsuario(data: any): User {
  const base = {
    id: data.userId ?? data.id ?? '',
    nombre: data.name ?? 'Sin Nombre',
    rol: data.role ?? 'cliente',
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
        direccion: data.address ?? 'Sin dirección',
        telefono: data.phone ?? 'Sin teléfono',
      } as Client;
  }
}

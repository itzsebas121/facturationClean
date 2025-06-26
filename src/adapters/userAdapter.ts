
import type { Admin, Client } from '../types/User';

export type User = Admin | Client;

export function adaptarUsuario(data: any): User {
  const base = {
    id: data.userId ?? data.id ?? '',
    nombre: data.name ?? 'Sin Nombre',
    telefono: data.phone ?? 'Sin teléfono',
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
        clientId: data.clientId ?? '',
        email: data.email ?? '',
        direccion: data.address ?? 'Sin dirección',
        telefono: data.phone ?? 'Sin teléfono',
      } as Client;
  }
}
export function adaptarCliente(data: any): Client {
  console.log(data)
  return {
    id: data.UserId ?? data.id ?? 0,
    clientId:data.ClientId??data.clientId??data.ClientID??0,
    primerNombre: data.FirstName,
    primerApellido: data.LastName,
    nombre: data.Name ?? data.FirstName + ' ' + data.LastName ?? 'Sin Nombre',
    rol: 'Client',
    email: data.Email ?? '',
    direccion: data.Address ?? 'Sin dirección',
    telefono: data.Phone ?? 'Sin teléfono',
    cedula: data.Cedula ?? '',
    isBlocked: data.IsBlocked ?? false,
    picture:data.Picture??data.PictureUrl??'',
  };
}
export interface BaseUser {
  id: string;
  clientId?: number;
  nombre: string;
  telefono: string;
  rol: 'Admin' | 'Client';
}

export interface Admin extends BaseUser {
  rol: 'Admin';
  email: string;
}

export interface Client extends BaseUser {
  rol: 'Client';
  primerNombre?: string;
  primerApellido?: string;
  email: string;
  direccion: string;
  telefono: string;
  cedula: string;
  isBlocked: boolean;
}

export type User = Admin | Client;

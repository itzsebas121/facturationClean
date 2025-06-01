export interface BaseUser {
  id: string;
  nombre: string;
  rol: 'Admin' | 'Client';
}

export interface Admin extends BaseUser {
  rol: 'Admin';
  email: string;
}

export interface Client extends BaseUser {
  rol: 'Client';
  email: string;
  direccion: string;
}

export type User = Admin | Client;

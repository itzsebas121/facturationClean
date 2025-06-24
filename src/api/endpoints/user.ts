import { API_BASE_URL } from "../config";
export const USER_ENDPOINTS = {
  LOGIN: `${API_BASE_URL}/api/user`,
  REGISTER: `${API_BASE_URL}/api/clients`,
  RECOVER: `${API_BASE_URL}/api/clients/recoverPassword`,
};

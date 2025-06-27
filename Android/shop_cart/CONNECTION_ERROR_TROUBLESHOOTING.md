# CONNECTION ERROR TROUBLESHOOTING GUIDE

## Issue Description
Users are experiencing "Connection reset by peer" errors when trying to change passwords or update profile information. This indicates that the backend endpoints are not properly implemented or accessible.

## Root Cause
The Flutter app is attempting to connect to backend endpoints that either:
1. Don't exist on the server
2. Are not properly configured
3. Have CORS issues
4. The server is down or unreachable

## Affected Endpoints
- `PUT /api/clients/changePassword` - Password change functionality
- `PUT /api/clients` - Profile update functionality  
- `GET /api/clients/{clientId}` - Get client information

## Current Status

### Backend Implementation Required
The backend server at `https://facturationclean.vercel.app` needs to implement these endpoints:

#### 1. Change Password Endpoint
```
PUT /api/clients/changePassword
Content-Type: application/json

Request Body:
{
  "userId": 123,
  "currentPassword": "current_password",
  "newPassword": "new_password"
}

Success Response (200):
{
  "Message": "Password changed successfully"
}

Error Responses:
400: { "Error": "Invalid data" }
401: { "Error": "Current password is incorrect" }
404: { "Error": "User not found" }
```

#### 2. Update Client Endpoint  
```
PUT /api/clients
Content-Type: application/json

Request Body:
{
  "clientId": 123,
  "cedula": "1234567890",
  "nombre": "John",
  "apellido": "Doe",
  "telefono": "555-0123",
  "direccion": "123 Main St",
  "email": "john@example.com"
}

Success Response (200):
{
  "Message": "Client updated successfully"
}

Error Responses:
400: { "Error": "Invalid data" }
404: { "Error": "Client not found" }
```

#### 3. Get Client Endpoint
```
GET /api/clients/{clientId}

Success Response (200):
{
  "clientId": 123,
  "cedula": "1234567890",
  "nombre": "John",
  "apellido": "Doe", 
  "telefono": "555-0123",
  "direccion": "123 Main St",
  "email": "john@example.com"
}

Error Responses:
404: { "Error": "Client not found" }
```

## Frontend Error Handling

### Current Implementation
The Flutter app has comprehensive error handling that:
- Catches connection errors and provides clear messages
- Implements 15-second timeouts to prevent hanging
- Uses fallback/mock data when endpoints are unavailable
- Shows user-friendly error dialogs
- Logs detailed error information for debugging

### Error Messages Shown to Users
- **Connection Issues**: "El servidor no está disponible. El endpoint no está implementado o el servidor está inactivo."
- **Timeout**: "Tiempo de espera agotado. Verifica tu conexión a internet."
- **SSL/TLS Issues**: "Error de seguridad SSL/TLS. Verifica la configuración del servidor."
- **Invalid Response**: "El servidor devolvió una respuesta inválida"

## Workarounds Currently Active

### 1. Profile Information
- App shows fallback data when `GET /api/clients/{clientId}` returns 404
- Users can still view and edit their profile (changes are sent to backend but may fail)
- Clear error messages inform users about backend issues

### 2. Password Changes
- App attempts to connect to `PUT /api/clients/changePassword` 
- If connection fails, users get a detailed error message
- No fallback since password changes must be server-side

### 3. Profile Updates
- App attempts to send updates to `PUT /api/clients`
- If connection fails, users get a detailed error message  
- Changes are not persisted without backend confirmation

## Testing the App

### With Current Backend
1. **Login**: ✅ Works (login endpoint is implemented)
2. **View Profile**: ✅ Works (uses fallback data)
3. **Edit Profile**: ❌ Fails with connection error
4. **Change Password**: ❌ Fails with connection error
5. **Cart Operations**: ✅ Works (most endpoints implemented)

### Expected Behavior After Backend Fix
All profile operations should work normally with proper success/error responses.

## Developer Instructions

### For Backend Developers
1. Implement the three missing endpoints listed above
2. Ensure CORS is properly configured for Flutter web
3. Test endpoints with Postman or similar tool
4. Verify SSL certificate is valid
5. Check server logs for any errors

### For Frontend Developers
1. The error handling is already comprehensive
2. Remove fallback data in `getCurrentClient()` once backend is ready
3. Update any hardcoded URLs if backend changes
4. Test all error scenarios after backend implementation

### For Testing
1. Use network monitoring tools to verify requests are being sent
2. Check browser console for CORS errors (if testing web version)
3. Test with airplane mode to verify offline error handling
4. Verify timeouts work correctly

## Backend Verification Checklist

Before declaring the backend "ready":
- [ ] `PUT /api/clients/changePassword` returns 200 for valid requests
- [ ] `PUT /api/clients` returns 200 for valid requests  
- [ ] `GET /api/clients/{clientId}` returns 200 for existing clients
- [ ] All endpoints return proper JSON error responses for invalid requests
- [ ] CORS headers allow Flutter app domain
- [ ] SSL certificate is valid and trusted
- [ ] Server stays responsive under load

## Quick Backend Test Commands

```bash
# Test change password (replace with actual data)
curl -X PUT https://facturationclean.vercel.app/api/clients/changePassword \
  -H "Content-Type: application/json" \
  -d '{"userId": 123, "currentPassword": "old", "newPassword": "new"}'

# Test update client (replace with actual data)  
curl -X PUT https://facturationclean.vercel.app/api/clients \
  -H "Content-Type: application/json" \
  -d '{"clientId": 123, "nombre": "Test", "apellido": "User", "email": "test@example.com"}'

# Test get client (replace with actual ID)
curl https://facturationclean.vercel.app/api/clients/123
```

Expected: All should return JSON responses, not connection errors.

## Next Steps

1. **Immediate**: Backend team implements missing endpoints
2. **Short-term**: Frontend team removes fallback data once backend is ready  
3. **Long-term**: Add more robust offline capabilities if needed

## Contact Information

If you continue experiencing connection issues after backend implementation:
1. Check network connectivity
2. Verify the app is using the correct backend URL
3. Test the backend endpoints directly with curl/Postman
4. Check server logs for any errors
5. Contact the development team with specific error messages

---
*Last updated: January 2025*
*Status: Backend endpoints need implementation*

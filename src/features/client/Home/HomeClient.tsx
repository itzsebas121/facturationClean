import { useEffect, useState } from "react"
import { useAuth } from "../../../auth/AuthContext"
import { adaptarCliente } from "../../../adapters/userAdapter"
import { updateClientService, changePasswordService, getClientsByUserIdService } from "../../../api/services/ClientService"
import { Alert } from "../../../components/UI/Alert"
import { ConfirmDialog } from "../../../components/UI/ConfirmDialog"
import { Client } from "../../../types/User"
import './HomeClient.css'

interface ProfileForm {
  primerNombre: string;
  primerApellido: string;
  email: string;
  telefono: string;
  direccion: string;
  cedula: string;
}

interface PasswordForm {
  currentPassword: string;
  newPassword: string;
  confirmPassword: string;
}

export function HomeClient() {
  const [client, setClient] = useState<Client | undefined>(undefined)
  const [profileForm, setProfileForm] = useState<ProfileForm>({
    primerNombre: '',
    primerApellido: '',
    email: '',
    telefono: '',
    direccion: '',
    cedula: ''
  })
  const [passwordForm, setPasswordForm] = useState<PasswordForm>({
    currentPassword: '',
    newPassword: '',
    confirmPassword: ''
  })
  const [isEditingProfile, setIsEditingProfile] = useState(false)
  const [isChangingPassword, setIsChangingPassword] = useState(false)
  const [showConfirmDialog, setShowConfirmDialog] = useState(false)
  const [confirmAction, setConfirmAction] = useState<'profile' | 'password' | null>(null)
  const [alert, setAlert] = useState<{ type: 'success' | 'error', message: string } | null>(null)
  const [isLoading, setIsLoading] = useState(false)

  const { user, loading } = useAuth()

  const showAlert = (type: 'success' | 'error', message: string) => {
    setAlert({ type, message })
    setTimeout(() => setAlert(null), 5000)
  }

  const getClient = async () => {
    try {
      if (!user?.clientId) {
        throw new Error("User ID is not available");
      }
      const data = await getClientsByUserIdService(Number(user.clientId));
      const adaptedClient = adaptarCliente(data);
      setClient(adaptedClient);
      setProfileForm({
        primerNombre: adaptedClient.primerNombre || '',
        primerApellido: adaptedClient.primerApellido || '',
        email: adaptedClient.email || '',
        telefono: adaptedClient.telefono || '',
        direccion: adaptedClient.direccion || '',
        cedula: adaptedClient.cedula || ''
      });
    } catch (error) {
      showAlert('error', 'Error al cargar la información del cliente');
      console.error('Error fetching client:', error);
    }
  }

  useEffect(() => {
    if (user?.id) {
      getClient()
    }
  }, [user?.id])

  const handleProfileInputChange = (field: keyof ProfileForm, value: string) => {
    setProfileForm(prev => ({
      ...prev,
      [field]: value
    }))
  }

  const handlePasswordInputChange = (field: keyof PasswordForm, value: string) => {
    setPasswordForm(prev => ({
      ...prev,
      [field]: value
    }))
  }

  const validateProfileForm = (): boolean => {
    if (!profileForm.primerNombre.trim()) {
      showAlert('error', 'El primer nombre es requerido');
      return false;
    }
    if (!profileForm.primerApellido.trim()) {
      showAlert('error', 'El primer apellido es requerido');
      return false;
    }
    if (!profileForm.email.trim()) {
      showAlert('error', 'El email es requerido');
      return false;
    }
    if (!profileForm.telefono.trim()) {
      showAlert('error', 'El teléfono es requerido');
      return false;
    }
    if (!profileForm.direccion.trim()) {
      showAlert('error', 'La dirección es requerida');
      return false;
    }
    if (!profileForm.cedula.trim()) {
      showAlert('error', 'La cédula es requerida');
      return false;
    }

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(profileForm.email)) {
      showAlert('error', 'Por favor ingrese un email válido');
      return false;
    }

    return true;
  }

  const validatePasswordForm = (): boolean => {
    if (!passwordForm.currentPassword) {
      showAlert('error', 'La contraseña actual es requerida');
      return false;
    }
    if (!passwordForm.newPassword) {
      showAlert('error', 'La nueva contraseña es requerida');
      return false;
    }
    if (passwordForm.newPassword.length < 6) {
      showAlert('error', 'La nueva contraseña debe tener al menos 6 caracteres');
      return false;
    }
    if (passwordForm.newPassword !== passwordForm.confirmPassword) {
      showAlert('error', 'Las contraseñas no coinciden');
      return false;
    }
    return true;
  }

  const handleProfileSubmit = async () => {
    if (!validateProfileForm() || !client) return;

    setIsLoading(true);
    try {
      const updatedClient = {
        ...client,
        primerNombre: profileForm.primerNombre,
        primerApellido: profileForm.primerApellido,
        email: profileForm.email,
        telefono: profileForm.telefono,
        direccion: profileForm.direccion,
        cedula: profileForm.cedula
      };

      const result = await updateClientService(updatedClient);
      if (result.error || result.Error) {
        showAlert('error', result.Error || result.error);
        console.error('Error updating profile:', result.error);
        return;
      } else {
        await getClient();

        setIsEditingProfile(false);
        showAlert('success', result.message || result.Message);;
      }

    } catch (error) {
      showAlert('error', 'Error al actualizar el perfil');
      console.error('Error updating profile:', error);
    } finally {
      setIsLoading(false);
    }
  }

  const handlePasswordSubmit = async () => {
    if (!validatePasswordForm() || !user?.clientId) return;

    setIsLoading(true);
    try {
      const result = await changePasswordService(
        Number(user.id),
        passwordForm.currentPassword,
        passwordForm.newPassword
      );
      if (result.error || result.Error) {
        showAlert('error', result.Error || result.error);
        console.error('Error changing password:', result.error);
        return;
      } else {
        setPasswordForm({
          currentPassword: '',
          newPassword: '',
          confirmPassword: ''
        });
        setIsChangingPassword(false);
        showAlert('success', result.Message || result.message);
      }

    } catch (error) {
      showAlert('error', 'Error al cambiar la contraseña. Verifique su contraseña actual.');
      console.error('Error changing password:', error);
    } finally {
      setIsLoading(false);
    }
  }

  const handleConfirmAction = () => {
    if (confirmAction === 'profile') {
      handleProfileSubmit();
    } else if (confirmAction === 'password') {
      handlePasswordSubmit();
    }
    setShowConfirmDialog(false);
    setConfirmAction(null);
  }

  const initiateAction = (action: 'profile' | 'password') => {
    setConfirmAction(action);
    setShowConfirmDialog(true);
  }

  if (loading) {
    return (
      <div className="loading-container">
        <div className="loading-spinner"></div>
        <p>Cargando...</p>
      </div>
    );
  }

  if (!client) {
    return (
      <div className="error-container">
        <p>No se pudo cargar la información del cliente</p>
      </div>
    );
  }

  return (
    <div className="home-client-container">
      {alert && (
        <Alert
          type={alert.type}
          message={alert.message}
          onClose={() => setAlert(null)}
        />
      )}

      <div className="client-header">
        <div className="client-avatar">
          <span>{client.primerNombre?.[0]?.toUpperCase() || 'C'}</span>
        </div>
        <div className="client-info">
          <h1>Bienvenido, {client.primerNombre} {client.primerApellido}</h1>
          <p className="client-role">Cliente</p>
        </div>
      </div>

      <div className="client-content">
        <div className="section-card">
          <div className="section-header">
            <h2>Información Personal</h2>
            <button
              className={`btn ${isEditingProfile ? 'btn-secondary' : 'btn-primary'}`}
              onClick={() => setIsEditingProfile(!isEditingProfile)}
              disabled={isLoading}
            >
              {isEditingProfile ? 'Cancelar' : 'Editar'}
            </button>
          </div>

          <div className="profile-form">
            <div className="form-grid">
              <div className="form-group">
                <label htmlFor="primerNombre">Primer Nombre</label>
                <input
                  id="primerNombre"
                  type="text"
                  value={profileForm.primerNombre}
                  onChange={(e) => handleProfileInputChange('primerNombre', e.target.value)}
                  disabled={!isEditingProfile}
                  className="form-input"
                />
              </div>

              <div className="form-group">
                <label htmlFor="primerApellido">Primer Apellido</label>
                <input
                  id="primerApellido"
                  type="text"
                  value={profileForm.primerApellido}
                  onChange={(e) => handleProfileInputChange('primerApellido', e.target.value)}
                  disabled={!isEditingProfile}
                  className="form-input"
                />
              </div>

              <div className="form-group">
                <label htmlFor="email">Email</label>
                <input
                  id="email"
                  type="email"
                  value={profileForm.email}
                  onChange={(e) => handleProfileInputChange('email', e.target.value)}
                  disabled={!isEditingProfile}
                  className="form-input"
                />
              </div>

              <div className="form-group">
                <label htmlFor="telefono">Teléfono</label>
                <input
                  id="telefono"
                  type="tel"
                  value={profileForm.telefono}
                  onChange={(e) => handleProfileInputChange('telefono', e.target.value)}
                  disabled={!isEditingProfile}
                  className="form-input"
                />
              </div>

              <div className="form-group">
                <label htmlFor="cedula">Cédula</label>
                <input
                  id="cedula"
                  type="text"
                  value={profileForm.cedula}
                  onChange={(e) => handleProfileInputChange('cedula', e.target.value)}
                  disabled={!isEditingProfile}
                  className="form-input"
                />
              </div>

              <div className="form-group full-width">
                <label htmlFor="direccion">Dirección</label>
                <textarea
                  id="direccion"
                  value={profileForm.direccion}
                  onChange={(e) => handleProfileInputChange('direccion', e.target.value)}
                  disabled={!isEditingProfile}
                  className="form-textarea"
                  rows={3}
                />
              </div>
            </div>

            {isEditingProfile && (
              <div className="form-actions">
                <button
                  className="btn btn-primary"
                  onClick={() => initiateAction('profile')}
                  disabled={isLoading}
                >
                  {isLoading ? 'Guardando...' : 'Guardar Cambios'}
                </button>
              </div>
            )}
          </div>
        </div>

        <div className="section-card">
          <div className="section-header">
            <h2>Cambiar Contraseña</h2>
            <button
              className={`btn ${isChangingPassword ? 'btn-secondary' : 'btn-primary'}`}
              onClick={() => setIsChangingPassword(!isChangingPassword)}
              disabled={isLoading}
            >
              {isChangingPassword ? 'Cancelar' : 'Cambiar'}
            </button>
          </div>

          {isChangingPassword && (
            <div className="password-form">
              <div className="form-group">
                <label htmlFor="currentPassword">Contraseña Actual</label>
                <input
                  id="currentPassword"
                  type="password"
                  value={passwordForm.currentPassword}
                  onChange={(e) => handlePasswordInputChange('currentPassword', e.target.value)}
                  className="form-input"
                  placeholder="Ingrese su contraseña actual"
                />
              </div>

              <div className="form-group">
                <label htmlFor="newPassword">Nueva Contraseña</label>
                <input
                  id="newPassword"
                  type="password"
                  value={passwordForm.newPassword}
                  onChange={(e) => handlePasswordInputChange('newPassword', e.target.value)}
                  className="form-input"
                  placeholder="Ingrese la nueva contraseña"
                />
              </div>

              <div className="form-group">
                <label htmlFor="confirmPassword">Confirmar Nueva Contraseña</label>
                <input
                  id="confirmPassword"
                  type="password"
                  value={passwordForm.confirmPassword}
                  onChange={(e) => handlePasswordInputChange('confirmPassword', e.target.value)}
                  className="form-input"
                  placeholder="Confirme la nueva contraseña"
                />
              </div>

              <div className="form-actions">
                <button
                  className="btn btn-primary"
                  onClick={() => initiateAction('password')}
                  disabled={isLoading}
                >
                  {isLoading ? 'Cambiando...' : 'Cambiar Contraseña'}
                </button>
              </div>
            </div>
          )}
        </div>
      </div>

      {showConfirmDialog && (
        <ConfirmDialog
          isOpen={showConfirmDialog}
          title={confirmAction === 'profile' ? 'Confirmar Actualización' : 'Confirmar Cambio de Contraseña'}
          message={
            confirmAction === 'profile'
              ? '¿Está seguro de que desea actualizar su información personal?'
              : '¿Está seguro de que desea cambiar su contraseña?'
          }
          onConfirm={handleConfirmAction}
          onCancel={() => {
            setShowConfirmDialog(false);
            setConfirmAction(null);
          }}
        />

      )}
    </div>
  )
}
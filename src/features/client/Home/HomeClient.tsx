import { useEffect, useState } from "react"
import { useAuth } from "../../../auth/AuthContext"
import { adaptarCliente } from "../../../adapters/userAdapter"
import { updateClientService, changePasswordService, getClientsByUserIdService, updateClientPictureService, uploadImage } from "../../../api/services/ClientService"
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
  const [confirmAction, setConfirmAction] = useState<'profile' | 'password' | 'picture' | null>(null)
  const [alert, setAlert] = useState<{ type: 'success' | 'error', message: string } | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const [selectedFile, setSelectedFile] = useState<File | null>(null)
  const [previewImage, setPreviewImage] = useState<string | null>(null)

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
      console.log(data)
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
    // Validaciones específicas para campos numéricos
    if (field === 'telefono') {
      const numericValue = value.replace(/\D/g, ''); // Solo números
      if (numericValue.length <= 10) {
        setProfileForm(prev => ({
          ...prev,
          [field]: numericValue
        }));
      }
      return;
    }

    if (field === 'cedula') {
      const numericValue = value.replace(/\D/g, ''); // Solo números
      if (numericValue.length <= 10) {
        setProfileForm(prev => ({
          ...prev,
          [field]: numericValue
        }));
      }
      return;
    }

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

  const handleImageSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (file) {
      // Validar tamaño del archivo (máximo 5MB)
      if (file.size > 5 * 1024 * 1024) {
        showAlert('error', 'La imagen debe ser menor a 5MB');
        return;
      }

      // Validar tipo de archivo
      if (!file.type.startsWith('image/')) {
        showAlert('error', 'Solo se permiten archivos de imagen');
        return;
      }

      setSelectedFile(file)
      const reader = new FileReader()
      reader.onload = (e) => {
        setPreviewImage(e.target?.result as string)
      }
      reader.readAsDataURL(file)
      setConfirmAction('picture')
      setShowConfirmDialog(true)
    }
  }

  const triggerFileInput = () => {
    const fileInput = document.getElementById('profile-picture-input') as HTMLInputElement
    fileInput?.click()
  }

  const validateProfileForm = (): boolean => {
    if (!profileForm.primerNombre.trim()) {
      showAlert('error', 'El nombre es requerido');
      return false;
    }
    if (!profileForm.primerApellido.trim()) {
      showAlert('error', 'El apellido es requerido');
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
    if (profileForm.telefono.length !== 10) {
      showAlert('error', 'El teléfono debe tener 10 dígitos');
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
    if ( profileForm.cedula.length !== 10) {
      showAlert('error', 'La cédula debe tener entre 10 dígitos');
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
    if (!passwordForm.currentPassword.trim()) {
      showAlert('error', 'La contraseña actual es requerida');
      return false;
    }
    if (!passwordForm.newPassword.trim()) {
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

  const handlePictureUpdate = async () => {
    if (!selectedFile || !client) return;

    setIsLoading(true);
    try {
      let imageUrl = client.picture;

      if (selectedFile) {
        const uploadedUrl = await uploadImage(selectedFile);
        imageUrl = uploadedUrl === null ? "https://upload.wikimedia.org/wikipedia/commons/a/a3/Image-not-found.png" : uploadedUrl;
        if (!imageUrl) showAlert("error", 'No se pudo subir la imagen');
      }
      const result: any = await updateClientPictureService(Number(client.clientId), String(imageUrl));

      if (result.error || result.Error) {
        showAlert('error', result.error || result.Error);
        return;
      }
      else {
        await getClient();
        setSelectedFile(null);
        setPreviewImage(null);
        showAlert('success', result.message || result.Message || 'Foto de perfil actualizada exitosamente');
      }



    } catch (error) {
      console.error('Error updating picture:', error);
      showAlert('error', 'Error al actualizar la foto de perfil');
    } finally {
      setIsLoading(false);
    }
  };

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
        showAlert('error', result.error || result.Error || 'Error al actualizar el perfil');
        return;
      } else {
        await getClient();
        setIsEditingProfile(false);
        showAlert('success', result.message || result.Message || 'Perfil actualizado con éxito');
      }

    } catch (error) {
      console.log('Error actualizando perfil:', error);
      showAlert('error', 'Error al actualizar el perfil');
    } finally {
      setIsLoading(false);
    }
  };

  const handlePasswordSubmit = async () => {
    if (!validatePasswordForm() || !user?.clientId) return;

    setIsLoading(true);
    try {
      const result = await changePasswordService(
        Number(user.id),
        passwordForm.currentPassword,
        passwordForm.newPassword
      );

      if (!result.success) {
        showAlert('error', result.message || 'Error al cambiar la contraseña');
        return;
      }

      setPasswordForm({
        currentPassword: '',
        newPassword: '',
        confirmPassword: ''
      });
      setIsChangingPassword(false);
      showAlert('success', result.message || 'Contraseña cambiada exitosamente');

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
    } else if (confirmAction === 'picture') {
      handlePictureUpdate();
    }
    setShowConfirmDialog(false);
    setConfirmAction(null);
  }

  const handleCancelAction = () => {
    if (confirmAction === 'picture') {
      setSelectedFile(null);
      setPreviewImage(null);
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

  const displayImage = previewImage || client.picture;

  return (
    <div className="home-client-container">
      {alert && (
        <Alert
          type={alert.type}
          message={alert.message}
          onClose={() => setAlert(null)}
        />
      )}

      <input
        id="profile-picture-input"
        type="file"
        accept="image/*"
        onChange={handleImageSelect}
        style={{ display: 'none' }}
      />

      <div className="client-header">
        <div className="profile-picture-container">
          <div className="client-avatar" onClick={triggerFileInput}>
            {displayImage ? (
              <img
                src={displayImage}
                alt="Profile"
                className="profile-image"
              />
            ) : (
              <span className="profile-initials">
                {client.primerNombre?.[0]?.toUpperCase() || 'C'}
              </span>
            )}
            <div className="photo-overlay">
              <div className="camera-icon">📷</div>
              <span className="change-photo-text">Cambiar foto</span>
            </div>
          </div>
        </div>
        <div className="client-info">
          <h1>Bienvenido, {client.primerNombre} {client.primerApellido}</h1>
          <p className="client-role">Cliente</p>
        </div>
      </div>

      <div className="client-content">
        <div className="content-grid">
          <div className="section-card profile-section">
            <div className="section-header">
              <h2>Información Personal</h2>
              <button
                className={`btn ${isEditingProfile ? 'btn-secondary' : 'btn-primary'}`}
                onClick={() => setIsEditingProfile(!isEditingProfile)}
                disabled={isLoading}
              >
                {isLoading && confirmAction === 'profile' ? (
                  <span className="btn-loading">
                    <div className="mini-spinner"></div>
                    Guardando...
                  </span>
                ) : (
                  isEditingProfile ? 'Cancelar' : 'Editar'
                )}
              </button>
            </div>

            <div className="profile-form">
              <div className="form-grid">
                <div className="form-group">
                  <label htmlFor="primerNombre">Nombre</label>
                  <input
                    id="primerNombre"
                    type="text"
                    value={profileForm.primerNombre}
                    onChange={(e) => handleProfileInputChange('primerNombre', e.target.value)}
                    disabled={!isEditingProfile}
                    className="form-input"
                    placeholder="Ingrese su nombre"
                    required
                  />
                </div>

                <div className="form-group">
                  <label htmlFor="primerApellido">Apellido</label>
                  <input
                    id="primerApellido"
                    type="text"
                    value={profileForm.primerApellido}
                    onChange={(e) => handleProfileInputChange('primerApellido', e.target.value)}
                    disabled={!isEditingProfile}
                    className="form-input"
                    placeholder="Ingrese su apellido"
                    required
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
                    placeholder="12345678"
                    maxLength={10}
                    required
                  />
                  <small className="field-hint">Solo números, 10 dígitos</small>
                </div>

                <div className="form-group">
                  <label htmlFor="telefono">Teléfono</label>
                  <input
                    id="telefono"
                    type="text"
                    value={profileForm.telefono}
                    onChange={(e) => handleProfileInputChange('telefono', e.target.value)}
                    disabled={!isEditingProfile}
                    className="form-input"
                    placeholder="1234567890"
                    maxLength={10}
                    required
                  />
                  <small className="field-hint">Solo números, 10 dígitos</small>
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
                    placeholder="ejemplo@correo.com"
                    required
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
                    rows={2}
                    placeholder="Ingrese su dirección completa"
                    required
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
                    {isLoading && confirmAction === 'profile' ? (
                      <span className="btn-loading">
                        <div className="mini-spinner"></div>
                        Guardando...
                      </span>
                    ) : (
                      'Guardar Cambios'
                    )}
                  </button>
                </div>
              )}
            </div>
          </div>

          <div className="section-card password-section">
            <div className="section-header">
              <h2>Cambiar Contraseña</h2>
              <button
                className={`btn ${isChangingPassword ? 'btn-secondary' : 'btn-primary'}`}
                onClick={() => setIsChangingPassword(!isChangingPassword)}
                disabled={isLoading}
              >
                {isLoading && confirmAction === 'password' ? (
                  <span className="btn-loading">
                    <div className="mini-spinner"></div>
                    Cambiando...
                  </span>
                ) : (
                  isChangingPassword ? 'Cancelar' : 'Cambiar'
                )}
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
                    required
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
                    placeholder="Mínimo 6 caracteres"
                    minLength={6}
                    required
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
                    placeholder="Repita la nueva contraseña"
                    required
                  />
                </div>

                <div className="form-actions">
                  <button
                    className="btn btn-primary"
                    onClick={() => initiateAction('password')}
                    disabled={isLoading}
                  >
                    {isLoading && confirmAction === 'password' ? (
                      <span className="btn-loading">
                        <div className="mini-spinner"></div>
                        Cambiando...
                      </span>
                    ) : (
                      'Cambiar Contraseña'
                    )}
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      </div>

      {showConfirmDialog && (
        <ConfirmDialog
          isOpen={showConfirmDialog}
          title={
            confirmAction === 'profile' ? 'Confirmar Actualización' :
              confirmAction === 'password' ? 'Confirmar Cambio de Contraseña' :
                'Confirmar Cambio de Foto'
          }
          message={
            confirmAction === 'profile'
              ? '¿Está seguro de que desea actualizar su información personal?'
              : confirmAction === 'password'
                ? '¿Está seguro de que desea cambiar su contraseña?'
                : '¿Está seguro de que desea cambiar su foto de perfil?'
          }
          onConfirm={handleConfirmAction}
          onCancel={handleCancelAction}
        />
      )}
    </div>
  )
}

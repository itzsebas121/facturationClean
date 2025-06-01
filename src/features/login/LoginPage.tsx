import React, { useState } from 'react';
import { useAuth } from '../../auth/AuthContext';
import { loginService } from '../../api/services/userService';

export function LoginPage() {
    const { login } = useAuth();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState(null);

    const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        setError(null);
        try {
            const { token } = await loginService({ email, password });
            if (token.Message) {
                setError(token.Message || 'Error al iniciar sesión');
            }
            login(token);
        } catch (err: any) {
            setError(err.message);
        }
    };
    return (
        <form onSubmit={handleSubmit}>
            <input type="email" placeholder="Email" value={email} onChange={e => setEmail(e.target.value)} required />
            <input type="password" placeholder="Password" value={password} onChange={e => setPassword(e.target.value)} required />
            <button type="submit">Entrar</button>
            {error && <p style={{ color: 'red' }}>{error}</p>}
        </form>
    );
}

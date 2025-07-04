const { poolPromise, sql } = require('../db/db');
const { logErrorToDB } = require('./errorLog');
const jwt = require('jsonwebtoken');
require('dotenv').config();

async function ValidateUserLogin(user) {
    try {
        const { email, password } = user;
        const pool = await poolPromise;
        const result = await pool.request()
            .input('Email', sql.VarChar(150), email)
            .input('Password', sql.VarChar(150), password)
            .execute('ValidateUserLogin');

        const userData = result.recordset[0];

        if (!userData) {
            logErrorToDB('UserService', 'ValidateUserLogin', `User with email: ${email} not found`, "");
            return null
        };
        if (!userData.UserId) return userData;

        const payload = {
            userId: userData.UserId,
            email: userData.Email,
            name: userData.Name,
            address: userData.Address,
            phone: userData.Phone,
            role: userData.Role
        };

        if (userData.Role === 'Client') {
            payload.clientId = userData.ClientId;
        }
        return jwt.sign(payload, process.env.SECRET_KEY, { expiresIn: '24h' });
    } catch (error) {
        logErrorToDB('UserService', 'ValidateUserLogin', error.message, error.stack);
    }
}

module.exports = {
    ValidateUserLogin,
};

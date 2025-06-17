const { poolPromise, sql } = require('../db/db');
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

        if (result.recordset.length === 0) {
            return null; 
        }

        const userData = result.recordset[0];
        if (!userData.UserId) {
            return userData;
        }
        const token = jwt.sign(
            {
                userId: userData.UserId,
                email: userData.Email,
                name: userData.Name,
                address: userData.Address,
                phone: userData.Phone,
                role: userData.Role
            },
            process.env.SECRET_KEY,
            { expiresIn: '24h' }
        );
        return token
    } catch (error) {
        throw error;
    }
}

module.exports = {
    ValidateUserLogin
};

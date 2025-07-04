const { poolPromise, sql } = require('../db/db');

async function logErrorToDB(controller, method, message, stack) {
    try {
        const pool = await poolPromise;
        await pool.request()
            .input('Controller', sql.NVarChar, controller)
            .input('Method', sql.NVarChar, method)
            .input('ErrorMessage', sql.NVarChar, message)
            .input('StackTrace', sql.NVarChar, stack)
            .query(`
                INSERT INTO ErrorLogs (Controller, Method, ErrorMessage, StackTrace)
                VALUES (@Controller, @Method, @ErrorMessage, @StackTrace)
            `);
    } catch (logErr) {
        console.error("Error al guardar en ErrorLogs:", logErr.message);
    }
}

module.exports = { logErrorToDB };

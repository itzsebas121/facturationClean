const { poolPromise, sql } = require('../db/db');
async function getAllClients() {
  const pool = await poolPromise;
  const result = await pool.request().execute('getClients');
  return result.recordset;
}

module.exports = {
    getAllClients,
};
const { poolPromise, sql } = require('../db/db');
async function getAllClients() {
  const pool = await poolPromise;
  const result = await pool.request().execute('getClients');
  return result.recordset;
}
async function createClient(client) {
  const pool = await poolPromise;
  const request = pool.request();
  request.input('Cedula', sql.VarChar(10), client.cedula);
  request.input('Email', sql.VarChar(100), client.email);
  request.input('Password', sql.VarChar(64), client.password);
  request.input('FirstName', sql.VarChar(100), client.firstName);
  request.input('LastName', sql.VarChar(100), client.lastName);
  request.input('Address', sql.VarChar(200), client.address || null);
  request.input('Phone', sql.VarChar(15), client.phone || null);
  const result = await request.execute('CreateClient');
  return result.recordset[0];
}

module.exports = {
  getAllClients,
  createClient,
};
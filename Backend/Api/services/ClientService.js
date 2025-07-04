const { poolPromise, sql } = require('../db/db');
const { logErrorToDB } = require('./errorLog');

async function getAllClients() {
  try {
    const pool = await poolPromise;
    const result = await pool.request().execute('getClients');
    return result.recordset;
  } catch (error) {
    logErrorToDB('ClientService', 'getAllClients', error.message, error.stack);
    throw error;
  }

}
async function getClientById(id) {
  try {
    const pool = await poolPromise;
    const result = await pool.request()
      .input('ClientId', sql.Int, id)
      .execute('getClientById');
    return result.recordset[0];
  } catch (error) {
    logErrorToDB('ClientService', 'getClientById', error.message, error.stack);
  }

}
async function createClient(client) {
  try {
    const pool = await poolPromise;
    const request = pool.request();
    request.input('Cedula', sql.VarChar(10), client.cedula);
    request.input('Email', sql.VarChar(100), client.email);
    request.input('Password', sql.VarChar(64), client.password);
    request.input('FirstName', sql.VarChar(100), client.firstName);
    request.input('LastName', sql.VarChar(100), client.lastName);
    request.input('Address', sql.VarChar(200), client.address || null);
    request.input('Phone', sql.VarChar(10), client.phone || null);
    const result = await request.execute('CreateClient');
    return result.recordset[0];
  }
  catch (error) {
    logErrorToDB('ClientService', 'createClient', error.message, error.stack);
  }

}
async function updateClient(client) {
  try {
    const pool = await poolPromise;
    const request = pool.request();
    request.input('ClientId', sql.Int, client.clientId);
    request.input('Cedula', sql.VarChar(10), client.cedula);
    request.input('Email', sql.VarChar(100), client.email);
    request.input('FirstName', sql.VarChar(100), client.firstName);
    request.input('LastName', sql.VarChar(100), client.lastName);
    request.input('Address', sql.VarChar(200), client.address || null);
    request.input('Phone', sql.VarChar(15), client.phone || null);

    const result = await request.execute('UpdateClient');
    return result.recordset[0];
  } catch (error) {
    logErrorToDB('ClientService', 'updateClient', error.message, error.stack);
  }
}
async function changePassword(userId, currentPassword, newPassword) {
  try {
    const pool = await poolPromise;
    const request = pool.request();
    request.input('UserId', sql.Int, userId);
    request.input('CurrentPassword', sql.VarChar(100), currentPassword);
    request.input('NewPassword', sql.VarChar(100), newPassword);
    const result = await request.execute('ChangePassword');
    return result.recordset[0];
  } catch (error) {
    logErrorToDB('ClientService', 'changePassword', error.message, error.stack);
  }
}

async function recoverPassword(email) {
  try {
    const pool = await poolPromise;
    const request = pool.request();
    request.input('Email', sql.VarChar(100), email);
    const result = await request.execute('RecoverPassword');
    return result.recordset[0];
  } catch (error) {
    logErrorToDB('ClientService', 'recoverPassword', error.message, error.stack);
  }
}
async function enableClient(clientId) {
  const pool = await poolPromise;
  const request = pool.request();
  request.input('ClientID', sql.Int, clientId);
  const result = await request.execute('enableClient');
  if (result.rowsAffected[0] === 0) {
    logErrorToDB('ClientService', 'enableClient', 'No se encontró el cliente con el ID proporcionado', null);
    return false;
  }
  return true;
}
async function disableClient(clientId) {
  const pool = await poolPromise;
  const request = pool.request();
  request.input('ClientID', sql.Int, clientId);
  const result = await request.execute('disableClient');
  if (result.rowsAffected[0] === 0) {
    logErrorToDB('ClientService', 'disableClient', 'No se encontró el cliente con el ID proporcionado', null);
    return false;
  }
  return true;
}
async function updatePicture(client) {
  try {
    const pool = await poolPromise;
    const request = pool.request();
    request.input('ClientId', sql.Int, client.clientId);
    request.input('ProfileImageUrl', sql.VarChar(500), client.picture);
    const result = await request.execute('UpdateClientPicture');
    return result.recordset[0];
  } catch (error) {
    logErrorToDB('ClientService', 'updatePicture', error.message, error.stack);
  }
}
module.exports = {
  getAllClients,
  createClient,
  updateClient,
  changePassword,
  getClientById,
  recoverPassword,
  enableClient,
  disableClient,
  updatePicture,
};
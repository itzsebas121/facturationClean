const { poolPromise, sql } = require('../db/db');
const { logErrorToDB } = require('./errorLog');

async function getAllCategorias() {
  try {
    const pool = await poolPromise;
    const result = await pool.request().execute('getCategories');
    return result.recordset;
  } catch (error) {
    logErrorToDB('CategorieService', 'getAllCategorias', error.message, error.stack);
  }
}

module.exports = {
  getAllCategorias,
};
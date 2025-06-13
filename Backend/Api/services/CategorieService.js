const { poolPromise, sql } = require('../db/db');

async function getAllCategorias() {
  const pool = await poolPromise;
  const result = await pool.request().execute('getCategories');
  return result.recordset;
}

module.exports = {
    getAllCategorias,
};
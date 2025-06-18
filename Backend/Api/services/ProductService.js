const { poolPromise, sql } = require('../db/db');

async function getAllProductos(filtro, page = 1, pageSize = 10, categoryId = null) {
  const pool = await poolPromise;

  const result = await pool
    .request()
    .input("FiltroGeneral", filtro || null)
    .input("CategoryId", categoryId ? parseInt(categoryId) : null)
    .input("Page", parseInt(page))
    .input("PageSize", parseInt(pageSize))
    .execute("getProducts");
  return {
    products: result.recordsets[0],
    total: result.recordsets[1][0]?.Total || 0
  };

}

async function createProducto(producto) {
  const { CategoryId, Name, Description, Price, Stock, ImageUrl } = producto;
  const pool = await poolPromise;

  const result = await pool.request()
    .input('CategoryId', sql.Int, CategoryId)
    .input('Name', sql.VarChar(150), Name)
    .input('Description', sql.VarChar(250), Description)
    .input('Price', sql.Decimal(12, 2), Price)
    .input('Stock', sql.Int, Stock)
    .input('ImageUrl', sql.VarChar(255), ImageUrl)
    .execute('CreateProduct');
  if (result.rowsAffected[0] === 0) return false;
  return result.recordset[0];
}
async function updateProducto(id, producto) {
  const { CategoryId, Name, Description, Price, Stock, ImageUrl } = producto;
  const pool = await poolPromise;

  const result = await pool.request()
    .input('ProductId', sql.Int, id)
    .input('CategoryId', sql.Int, CategoryId)
    .input('Name', sql.VarChar(150), Name)
    .input('Description', sql.VarChar(250), Description)
    .input('Price', sql.Decimal(12, 2), Price)
    .input('Stock', sql.Int, Stock)
    .input('ImageUrl', sql.VarChar(255), ImageUrl)
    .execute('UpdateProduct');
  if (result.rowsAffected[0] === 0) return false;
  return true;
}

async function deleteProducto(id) {
  const pool = await poolPromise;

  const result = await pool.request()
    .input('ProductId', sql.Int, id)
    .execute('DeleteProduct');
  if (result.rowsAffected[0] === 0) return false;
  return true;
}


module.exports = {
  getAllProductos,
  createProducto,
  updateProducto,
  deleteProducto,
};

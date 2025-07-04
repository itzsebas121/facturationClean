const { poolPromise, sql } = require('../db/db');
const { logErrorToDB } = require('./errorLog');

async function getAllProductos(filtro, page = 1, pageSize = 10, categoryId = null, isAdmin = false) {
  const pool = await poolPromise;

  const result = await pool
    .request()
    .input("FiltroGeneral", filtro || null)
    .input("CategoryId", categoryId ? parseInt(categoryId) : null)
    .input("Page", parseInt(page))
    .input("PageSize", parseInt(pageSize))
    .input("EsAdmin", isAdmin ? 1 : 0)
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
  if (result.rowsAffected[0] === 0) {
    logErrorToDB('ProductService', 'createProducto', 'No se pudo crear el producto', null);
    return false
  };
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
  if (result.rowsAffected[0] === 0) {
    logErrorToDB('ProductService', 'updateProducto', `No se pudo actualizar ${producto.id} el producto`, null);
    return false
  };
  return true;
}

async function disableProduct(id) {
  const pool = await poolPromise;

  const result = await pool.request()
    .input('ProductId', sql.Int, id)
    .execute('disableProduct');
  if (result.rowsAffected[0] === 0) {
    logErrorToDB('ProductService', 'disableProduct', `No se pudo deshabilitar el producto ${id}`, null);
    return false
  };
  return true;
}
async function enableProduct(id) {
  const pool = await poolPromise;
  const result = await pool.request()
    .input('ProductId', sql.Int, id)
    .execute('enableProduct');
  if (result.rowsAffected[0] === 0) {
    logErrorToDB('ProductService', 'enableProduct', `No se pudo habilitar el producto ${id}`, null);
    return false
  };
  return true;
}


module.exports = {
  getAllProductos,
  createProducto,
  updateProducto,
  disableProduct,
  enableProduct

};

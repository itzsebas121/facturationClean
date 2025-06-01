const { poolPromise, sql } = require('../db/db');

async function getAllProductos(filtro, page = 1, pageSize = 10) {
  const pool = await poolPromise;

  const result = await pool
    .request()
    .input("FiltroGeneral", filtro || null)
    .input("Page", parseInt(page))
    .input("PageSize", parseInt(pageSize))
    .execute("getProducts");

  return result.recordset;
}
//Pendiente editar
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
    .query(`
      INSERT INTO Products (CategoryId, Name, Description, Price, Stock, ImageUrl)
      VALUES (@CategoryId, @Name, @Description, @Price, @Stock, @ImageUrl);
      SELECT SCOPE_IDENTITY() AS ProductId;
    `);
  return result.recordset[0];
}
// Pendiente editar
async function updateProducto(id, producto) {
  const { CategoryId, Name, Description, Price, Stock, ImageUrl } = producto;
  const pool = await poolPromise;
  await pool.request()
    .input('ProductId', sql.Int, id)
    .input('CategoryId', sql.Int, CategoryId)
    .input('Name', sql.VarChar(150), Name)
    .input('Description', sql.VarChar(250), Description)
    .input('Price', sql.Decimal(12, 2), Price)
    .input('Stock', sql.Int, Stock)
    .input('ImageUrl', sql.VarChar(255), ImageUrl)
    .query(`
      UPDATE Products SET 
      CategoryId = @CategoryId, 
      Name = @Name,
      Description = @Description,
      Price = @Price,
      Stock = @Stock,
      ImageUrl = @ImageUrl
      WHERE ProductId = @ProductId
    `);
  return true;
}
// Pendiente editar
async function deleteProducto(id) {
  const pool = await poolPromise;
  await pool.request()
    .input('ProductId', sql.Int, id)
    .query('DELETE FROM Products WHERE ProductId = @ProductId');
  return true;
}

module.exports = {
  getAllProductos,
  createProducto,
  updateProducto,
  deleteProducto,
};

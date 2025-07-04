const categorieService = require('../services/CategorieService');
const { logErrorToDB } = require('../services/errorLog');
async function getAll(req, res) {
  try {
    const categorias = await categorieService.getAllCategorias();
    res.json(categorias);
  } catch (error) {
    await logErrorToDB('CategorieController', 'getAll', error.message, error.stack);
    res.status(500).json({ message: "Error al obtener categorías", error });
  }
}
module.exports = {
  getAll,
};
const categorieService = require('../services/CategorieService');
async function getAll(req, res) {
  try {
    const categorias = await categorieService.getAllCategorias();
    res.json(categorias);
  } catch (error) {
    console.error("❌ Error al obtener categorías:", error);
    res.status(500).json({ message: "Error al obtener categorías", error });
  }
}
module.exports = {
  getAll,
};
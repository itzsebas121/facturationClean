const productosService = require('../services/ProductService');

async function getAll(req, res) {
  const { filtro, page = 1, pageSize = 10, categoryId } = req.query;

  try {
    const productos = await productosService.getAllProductos(filtro, page, pageSize, categoryId);
    res.json(productos);
  } catch (error) {
    console.error("❌ Error al obtener productos:", error);
    res.status(500).json({ message: "Error al obtener productos", error });
  }
}


async function create(req, res) {
  try {
    const producto = req.body;
    const newProducto = await productosService.createProducto(producto);
    res.status(201).json(newProducto);
  } catch (error) {
    res.status(500).json({ message: "Error al crear producto", error });
  }
}

async function update(req, res) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ message: "ID inválido" });

    const producto = req.body;
    await productosService.updateProducto(id, producto);
    res.json({ message: "Producto actualizado" });
  } catch (error) {
    res.status(500).json({ message: "Error al actualizar producto", error });
  }
}

async function remove(req, res) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ message: "ID inválido" });

    await productosService.deleteProducto(id);
    res.json({ message: "Producto eliminado" });
  } catch (error) {
    res.status(500).json({ message: "Error al eliminar producto", error });
  }
}

module.exports = {
  getAll,
  create,
  update,
  remove,
};

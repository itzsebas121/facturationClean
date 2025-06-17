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
    if (!newProducto) {
      return res.status(400).json({ create: false });
    }
    res.status(201).json({create: true, message: "Producto creado exitosamente", productId: newProducto.ProductId });
  } catch (error) {
    res.status(500).json({ message: "Error al crear producto", error });
  }
}

async function update(req, res) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ message: "ID inválido" });

    const producto = req.body;
    const result = await productosService.updateProducto(id, producto);
    if (!result) {
      return res.status(400).json({ update: false, message: "No se pudo actualizar el producto" });
    }
    res.json({ update: true, message: "Producto actualizado" });
  } catch (error) {
    res.status(500).json({ message: "Error al actualizar producto", error });
  }
}

async function remove(req, res) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ message: "ID inválido" });

    const result = await productosService.deleteProducto(id);
    if (!result) 
      return res.status(400).json({ delete: false, message: "No se pudo eliminar el producto" });
    
    res.json({ delete:true, message: "Producto eliminado" });
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

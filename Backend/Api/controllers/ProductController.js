const productsService = require('../services/ProductService');
const { logErrorToDB } = require('../services/errorLog');

async function getAll(req, res) {
  const { filtro, page = 1, pageSize = 10, categoryId, isAdmin } = req.query;

  try {
    const productos = await productsService.getAllProductos(filtro, page, pageSize, categoryId, isAdmin);
    res.json(productos);
  } catch (error) {
    logErrorToDB("ProductController", "getAll", error.message, error.stack);
    res.status(500).json({ message: "Error al obtener productos", error });
  }
}


async function create(req, res) {
  try {
    const producto = req.body;
    const newProducto = await productsService.createProducto(producto);
    if (!newProducto) {
      logErrorToDB("ProductController", "create", newProducto.error||newProducto.Error||"Error al crear el producto", "");
      return res.status(400).json({ create: false });
    }
    res.status(201).json({ create: true, message: "Producto creado exitosamente", productId: newProducto.ProductId });
  } catch (error) {
    res.status(500).json({ message: "Error al crear producto", error });
    logErrorToDB("ProductController", "create", error.message, error.stack);
  }
}

async function update(req, res) {
  try {
    const id = parseInt(req.params.id, 10);
    if (isNaN(id)) return res.status(400).json({ error: "ID inválido" });

    const producto = req.body;
    const result = await productsService.updateProducto(id, producto);
    if (!result) {
      logErrorToDB("ProductController", "update", result.error||result.Error||"Error al actualizar el producto", "");
      return res.status(400).json({ update: false, error: "No se pudo actualizar el producto" });
    }
    res.json({ update: true, message: "Producto actualizado" });
  } catch (error) {
    res.status(500).json({ Error: "Error al actualizar producto ", error });
    logErrorToDB("ProductController", "update", error.message, error.stack);
  }
}

async function disable(req, res) {
  try {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "ID inválido" });

    const result = await productsService.disableProduct(id);
    if (!result){
      logErrorToDB("ProductController", "disable", result.error||result.Error||"Error al inhabilitar el producto", "");
      return res.status(400).json({ delete: false, message: "No se pudo inhabilitar el producto" });
    }

    res.json({ delete: true, message: "Producto desahabilitado exitosamente" });
  } catch (error) {
    res.status(500).json({ message: "Error al deshabilitar producto", error });
  }
}
async function enable (req, res) {
  try {
    const id = parseInt(req.params.id);
    if (isNaN(id)) return res.status(400).json({ message: "ID inválido" });
    const result = await productsService.enableProduct(id);
    if (!result){
      logErrorToDB("ProductController", "enable", result.error||result.Error||"Error al habilitar el producto", "");
      return res.status(400).json({ delete: false, message: "No se pudo habilitar el producto" });
    }

    res.json({ delete: true, message: "Producto habilitado exitosamente" });
  } catch (error) {
    logErrorToDB("ProductController", "enable", error.message, error.stack);
    res.status(500).json({ message: "Error al habilitar producto", error });
  }
}

module.exports = {
  getAll,
  create,
  update,
  disable,
  enable
};

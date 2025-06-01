const express = require('express');
const router = express.Router();
const productosController = require('../controllers/ProductController');

router.get('/', productosController.getAll);
router.post('/', productosController.create);
router.put('/:id', productosController.update);
router.delete('/:id', productosController.remove);

module.exports = router;

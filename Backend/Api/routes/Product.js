const express = require('express');
const router = express.Router();
const productosController = require('../controllers/ProductController');

router.get('/', productosController.getAll);
router.post('/', productosController.create);
router.put('/:id', productosController.update);
router.put('/disable/:id', productosController.disable);
router.put('/enable/:id', productosController.enable);

module.exports = router;

const express = require('express');
const router = express.Router();
const ordersController = require('../controllers/OrderController');

router.get('/', ordersController.getAll);
router.get('/:id', ordersController.getById);
router.post('/', ordersController.create);
router.post('/addDetail', ordersController.addProductToOrder);

module.exports = router;

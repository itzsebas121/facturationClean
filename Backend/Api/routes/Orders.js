const express = require('express');
const router = express.Router();
const ordersController = require('../controllers/OrderController');

router.get('/', ordersController.getAll);
router.get('/nextOrder', ordersController.getNextOrderId)
router.post('/', ordersController.create);
router.post('/addDetail', ordersController.addProductToOrder);
router.get('/:id', ordersController.getById);

module.exports = router;

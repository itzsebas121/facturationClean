const express = require('express');
const router = express.Router();
const clientController = require('../controllers/ClientController');
router.get('/', clientController.getAll);
router.post('/', clientController.create);
router.put('/', clientController.update);
router.put('changePassword', clientController.changePassword);
module.exports = router;
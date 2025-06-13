const express = require('express');
const router = express.Router();
const categorieController = require('../controllers/CategorieController');
router.get('/', categorieController.getAll);

module.exports = router;
const userService = require('../services/UserService');
async function validateUserLogin(req, res) {
  try {
    const user = req.body;
    const token = await userService.ValidateUserLogin(user);
    res.json({token});
  } catch (error) {
    res.status(500).json({ message: "Error al loguearse", error });
  }
}

module.exports = {
  validateUserLogin
};  


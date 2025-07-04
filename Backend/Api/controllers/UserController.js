const userService = require('../services/UserService');
const {  logErrorToDB } = require('../services/errorLog');
async function validateUserLogin(req, res) {
  try {
    const user = req.body;
    const token = await userService.ValidateUserLogin(user);
    if (token.error || token.Error || token.Message) {
      await logErrorToDB("UserController", "validateUserLogin", `Inicio de sesion fallido: ${user.email}`, "");
    }
    res.json({ token });
  } catch (error) {
    await logErrorToDB("UserController", "validateUserLogin", error.message, error.stack);
    res.status(500).json({ message: "Error al loguearse", error });
  }
}

module.exports = {
  validateUserLogin,
};


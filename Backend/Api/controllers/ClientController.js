const clientService = require("../services/ClientService.js")

async function getAll(req, res) {
    try {
        const clients = await clientService.getAllClients();
        res.json(clients);
    }
    catch (error) {
        console.error("❌ Error al obtener clientes:", error);
        res.status(500).json({ message: "Error al obtener clientes", error });
    }
}
async function getById(req, res) {
    try {
        const clientId = req.params.id;
        const client = await clientService.getClientById(clientId);
        res.json(client);
    }
    catch (error) {
        res.status(500).json({ message: "Error al obtener cliente", error });
    }
}
async function create(req, res) {
    try {
        const client = req.body;
        const newClient = await clientService.createClient(client);
        res.status(201).json({message: "Cliente creado con éxito", newClient});
    }
    catch (error) {
        console.log("Error al crear cliente:", error);
        res.status(500).json({ error: "Error al crear cliente", error });
    }
}
async function update(req, res) {
    try {
        const client = req.body;
        const updatedClient = await clientService.updateClient(client);
        res.json(updatedClient);
    }
    catch (error) {
        res.status(500).json({ error: "Error al actualizar cliente", error });
    }
}
async function changePassword(req, res) {
    try {
        const { userId, currentPassword, newPassword } = req.body;
        const updatedClient = await clientService.changePassword(userId, currentPassword, newPassword);
        res.json(updatedClient);
    }
    catch (error) {
        res.status(500).json({ message: "Error al cambiar contraseña", error });
    }
}
async function recoverPassword(req, res) {
    try {
        const { email } = req.body;
        const updatedClient = await clientService.recoverPassword(email);
        res.json(updatedClient);
    }
    catch (error) {
        res.status(500).json({ message: "Error al recuperar contraseña", error });
    }
}
async function enable(req, res) {
    try {
        const clientId = req.params.id;
        const updatedClient = await clientService.enableClient(clientId);
        if (!updatedClient) {
            return res.status(404).json({ enable: false, error: "No se pudo habilitar el cliente" });
        }
        return res.json({ enable: true, message: "Cliente habilitado exitosamente" });
    }
    catch (error) {
        res.status(500).json({ error: "Error al habilitar cliente", error });
    }

}
async function disable(req, res) {
    try {
        const clientId = req.params.id;
        const updatedClient = await clientService.disableClient(clientId);
        if (!updatedClient) {
            return res.status(404).json({ disable: false, error: "No se pudo deshabilitar el cliente" });
        }
        return res.json({ disable: true, message: "Cliente deshabilitado exitosamente" });
    }
    catch (error) {
        res.status(500).json({ error: "Error al deshabilitar cliente", error });
    }

}
module.exports = {
    getAll,
    create,
    update,
    getById,
    changePassword,
    recoverPassword,
    enable,
    disable
};

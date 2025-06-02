const express = require("express");
const cors = require("cors");
const app = express();
const port = process.env.PORT || 3000;

const productosRouter = require("./routes/Product");
const userRouter = require("./routes/User");

app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
  allowedHeaders: ["Content-Type", "Authorization"],
}));
app.use(express.json());

app.use("/api/productos", productosRouter);
app.use("/api/user", userRouter);

app.listen(port, () => {
  console.log(`🚀 Server ready on http://localhost:${port}`);
});

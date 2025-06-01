const express = require("express");
const cors = require("cors");

const productosRouter = require("./routes/Product");
const userRouter = require("./routes/User");
const app = express();
const port = process.env.PORT || 3000;

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

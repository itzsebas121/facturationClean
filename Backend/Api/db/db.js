const sql = require("mssql");
require("dotenv").config();

const config = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  server: process.env.DB_SERVER,
  database: process.env.DB_DATABASE,
  port: parseInt(process.env.DB_PORT, 10),
  options: {
    encrypt: true,
    trustServerCertificate: true,
  },
};

const poolPromise = sql.connect(config)
  .then(pool => {
    console.log("Connected to SQL Server");
    return pool;
  })
  .catch(err => {
    console.error("DB Connection Failed:", err);
    throw err;
  });

module.exports = {
  sql,
  poolPromise
};

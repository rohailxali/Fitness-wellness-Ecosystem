const oracledb = require('oracledb');
require('dotenv').config();

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;

const dbConfig = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  connectString: process.env.DB_CONNECT_STRING,
};

async function getConnection() {
  return await oracledb.getConnection(dbConfig);
}

async function execute(sql, binds = [], opts = {}) {
  let conn;
  try {
    conn = await getConnection();
    const result = await conn.execute(sql, binds, { outFormat: oracledb.OUT_FORMAT_OBJECT, ...opts });
    return result;
  } finally {
    if (conn) await conn.close();
  }
}

module.exports = { execute, getConnection };

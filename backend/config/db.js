const oracledb = require('oracledb');
require('dotenv').config();

try {
  oracledb.initOracleClient();
} catch (err) {
  console.error('Oracle Thick mode error (ignored if Oracle client is absent):', err);
}

oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;

const dbConfig = {
  user: process.env.DB_USER || 'ecosystem',
  password: process.env.DB_PASSWORD || 'ecosystem123',
  connectString: process.env.DB_CONNECT_STRING || 'localhost/XE',
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

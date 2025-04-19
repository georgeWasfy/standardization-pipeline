import knex from "knex";
import config from "../knexconfig";

const db = knex(config.development);

export default db;

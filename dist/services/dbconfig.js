"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const mysql_1 = __importDefault(require("mysql"));
exports.db = mysql_1.default.createConnection({
    host: "localhost",
    user: "root",
    password: "Aijaz123!",
    database: 'learning'
});
//# sourceMappingURL=dbconfig.js.map
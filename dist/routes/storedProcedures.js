"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const dbconfig_1 = require("../services/dbconfig");
const sp = express_1.default.Router();
exports.sp = sp;
sp.get('/', (req, res) => {
    console.log();
    dbconfig_1.db.query(`CREATE PROCEDURE get_collaborations(IN cid INT)
    BEGIN
    SELECT * FROM collaborations WHERE id=cid;
    END;`, (err, result) => {
        if (err)
            throw err;
        res.send(result);
    });
});
sp.get('/coll', (req, res) => {
    dbconfig_1.db.query(`CALL get_collaborations(1)`, (err, result) => {
        if (err)
            throw err;
        res.send(result);
    });
});
//# sourceMappingURL=storedProcedures.js.map
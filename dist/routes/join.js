"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const router = express_1.default.Router();
exports.router = router;
const dbconfig_1 = require("../services/dbconfig");
console.log("log");
router.use('/innerjoin', (req, res) => {
    console.log("===");
    dbconfig_1.db.query(`
    SELECT * FROM collaborations 
    INNER JOIN 
    tickets 
    ON 
    collaborations.id = tickets.collaborationId
    `, (err, result) => {
        console.log("result", result);
    });
    res.send("join");
});
router.use('/leftjoin', (req, res) => {
    dbconfig_1.db.query(`SELECT * FROM collaborations
    LEFT JOIN
    tickets
    ON
    collaborations.id = tickets.collaborationId
    `, (err, result) => {
        console.log("err", err);
        console.log("result", result);
        res.send(result);
    });
});
router.use('/rightjoin', (req, res) => {
    dbconfig_1.db.query(`SELECT * FROM collaborations
    RIGHT JOIN
    tickets
    ON
    collaborations.id = tickets.collaborationId
    `, (err, result) => {
        console.log("err", err);
        console.log("result", result);
        res.send(result);
    });
});
router.use('/fulljoin', (req, res) => {
    dbconfig_1.db.query(`SELECT * FROM collaborations FULL JOIN tickets`, (err, result) => {
        console.log("err", err);
        console.log("result", result);
        res.send(result);
    });
});
//# sourceMappingURL=join.js.map
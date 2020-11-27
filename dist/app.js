"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const express_1 = __importDefault(require("express"));
const mysql_1 = __importDefault(require("mysql"));
const join_1 = require("./routes/join");
const storedProcedures_1 = require("./routes/storedProcedures");
const dotenv_1 = __importDefault(require("dotenv"));
dotenv_1.default.config();
exports.connection = mysql_1.default.createConnection({
    host: "localhost",
    user: "root",
    password: "Aijaz123!",
    database: 'learning'
});
exports.connection.connect(err => {
    if (err)
        throw err;
    console.log("connection success !");
});
const app = express_1.default();
const port = 3000;
app.use(express_1.default.json());
app.use(express_1.default.urlencoded({ extended: true }));
app.get('/', (req, res) => {
    exports.connection.query(`SELECT * FROM learning.collaborations`, function (err, data) {
        if (err) {
            console.log("errr", err);
            res.send(err);
        }
        console.log("data", data);
        res.send(data);
    });
});
app.use('/add', (req, res) => {
    exports.connection.query(`INSERT INTO learning.collaborations (name, low, medium, high, friends) VALUES ('AIjaz', 1,1,1,'["test"]')`, function (err, result, fields) {
        console.log("err", err);
        console.log("result", result);
        console.log("field", fields);
    });
});
app.use('/procedure', (req, res) => {
    exports.connection.query('CALL learning.create_collaboration()', function (err, result) {
        console.log("err", err);
        console.log("result", result);
    });
});
app.use('/create/ticket', (req, res) => {
    exports.connection.query(`CALL create_ticket('open','medium',2,'test 2')`, function (err, result, fields) {
        console.log("error", err);
        console.log("result", result, fields);
        res.send(result);
    });
});
app.use('/join', join_1.router);
app.use('/sp', storedProcedures_1.sp);
console.log("env", process.env.host);
app.listen(port, () => {
    return console.log(`server is listening on ${port}`);
});
//# sourceMappingURL=app.js.map
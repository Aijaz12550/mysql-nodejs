import express from 'express';
import mysql from "mysql";
import { router } from "./routes/join"
export const connection = mysql.createConnection({
    host: "localhost",
    user: "root",
    password: "Aijaz123!",
    database: 'learning'
})
connection.connect(err => {
    if (err) throw err;
    console.log("connection success !");
})
const app = express();
const port = 3000;
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.get('/', (req, res) => {
    connection.query(`SELECT * FROM learning.collaborations`, function (err, data) {
        if (err) {
            console.log("errr", err);
            res.send(err)
        }
        console.log("data", data);
        res.send(data)
    })
});

app.use('/add', (req, res) => {
    connection.query(`INSERT INTO learning.collaborations (name, low, medium, high, friends) VALUES ('AIjaz', 1,1,1,'["test"]')`, function (err, result, fields) {
        console.log("err", err);
        console.log("result", result);
        console.log("field", fields);
    })
})
app.use('/procedure', (req, res) => {
    connection.query('CALL learning.create_collaboration()', function (err, result) {
        console.log("err", err);
        console.log("result", result);

    })
})

app.use('/create/ticket', (req, res) => {
    connection.query(`CALL create_ticket('open','medium',2,'test 2')`, function (err, result,fields) {
        console.log("error", err);
        console.log("result", result, fields);
        res.send(result)
    })
})

app.use('/join', router)

app.listen(port, () => {
    return console.log(`server is listening on ${port}`);
});
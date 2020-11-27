import express from "express"
import { db } from "../services/dbconfig"
const sp = express.Router();

sp.get('/', (req, res) => {
    console.log();
    db.query(`CREATE PROCEDURE get_collaborations(IN cid INT)
    BEGIN
    SELECT * FROM collaborations WHERE id=cid;
    END;`,
        (err, result) => {
            if (err) throw err;
            res.send(result)
        }
    )

})

sp.get('/coll', (req, res) => {
    db.query(`CALL get_collaborations(1)`,
        (err, result) => {
            if (err) throw err;
            res.send(result)
        }
    )
})

export { sp }
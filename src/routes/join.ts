import express from "express";
const router = express.Router();
import { db } from "../services/dbconfig"
console.log("log");

router.use('/innerjoin', (req, res) => {
    console.log("===");
    db.query(`
    SELECT * FROM collaborations 
    INNER JOIN 
    tickets 
    ON 
    collaborations.id = tickets.collaborationId
    `,
        (err, result) => {
            console.log("result", result);

        })
    res.send("join")
})


router.use('/leftjoin', (req, res) => {
    db.query(`SELECT * FROM collaborations
    LEFT JOIN
    tickets
    ON
    collaborations.id = tickets.collaborationId
    `, (err, result) => {
        console.log("err", err);
        console.log("result", result);

        res.send(result)
    })
})
export { router };

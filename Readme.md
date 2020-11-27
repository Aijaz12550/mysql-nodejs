
# SQL With Nodejs

## INNER JOIN

Inner join will return the value which is overlap in both tables.
Consider the following query:
```
 db.query(`
    SELECT * FROM collaborations 
    INNER JOIN 
    tickets 
    ON 
    collaborations.id = tickets.collaborationId
    `,
        (err, result) => {
            if(err){
                res.status(400).send(err)
            }
            res.send(result)
        })
```
It will returns only those collaborations which fulfill the condition (collaborations.id = tickets.collaborationId),
 with their respective tickets.

 ## LEFT JOIN
 
 Left join will return the all values of left table and overlapping values of the right table.
 Consider the following query :

 ```
db.query(`SELECT * FROM collaborations
    LEFT JOIN
    tickets
    ON
    collaborations.id = tickets.collaborationId
    `, (err, result) => {
            if(err){
                res.status(400).send(err)
            }
            res.send(result)
        })
 ```
 In this example we will get all the collaborations which is contain by collaborations table
 and only those tickets which fulfill this ( collaborations.id = tickets.collaborationId ) condition.
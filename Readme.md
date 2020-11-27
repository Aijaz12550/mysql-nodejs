
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

  ## RIGHT JOIN
 
 Right join will return the all values of right table and overlapping values of the left table.
 Consider the following query :

 ```
db.query(`SELECT * FROM collaborations
    RIGHT JOIN
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
 In this example we will get all the tickets which is contain by tickets table
 and only those collaborations which fulfill this ( collaborations.id = tickets.collaborationId ) condition.

 ## Stored Procedure

* A stored procedure is a prepared SQL code that you can save, so the code can be reused over and over again.
* So if you have an SQL query that you write over and over again, save it as a stored procedure, and then just call it to execute it.
* You can also pass parameters to a stored procedure, so that the stored procedure can act based on the parameter value(s) that is passed.
  

 ### Create Procedure

Following is the very basic example of creating stored procedure.

```
CREATE PROCEDURE get_collaborations(IN cid INT)
    BEGIN
    SELECT * FROM collaborations WHERE id=cid;
    END;
```

### How to use a Procedure?
 Very simple.
```
CALL get_collaborations(1)
```

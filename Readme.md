
# SQL With Nodejs

## INNER JOINS
```
Inner join will return the value which is overlap in both tables.
Consider the following query:

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

It will returns only those collaborations which fulfill the condition (collaborations.id = tickets.collaborationId),
 with their respective tickets.
```
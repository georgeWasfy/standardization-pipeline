# Data import

To import CSV dumps:
* download files to directory where they would be accessible for your DB
* create DB tables using:
`db_structure_mysql.sql`
or
`db_structure_postgresql.sql`
* import data to DB using:
`import_mysql.sh <hostname> <port> <username> <database>`
or 
`import_postgresql.sh <hostname> <port> <username> <database>`
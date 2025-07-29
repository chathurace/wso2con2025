import ballerinax/mysql;
import ballerinax/mysql.driver as _;

final mysql:Client salesDB = check new (dbHost, dbUser, dbPass, "salesDB", 3306);
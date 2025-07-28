import ballerina/sql;
import ballerinax/mysql;
import ballerinax/mysql.driver as _;

final mysql:Client salesDB = check new ("mysql-2da266014d9048c9a7ceffbdacb0daa3-salesdb3752116987-choreo.f.aivencloud.com", "avnadmin", dbPass, "salesDB", 20552);

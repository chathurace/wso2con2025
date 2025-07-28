import ballerina/data.csv;
import ballerina/ftp;
import ballerina/http;
import ballerina/io;
import ballerina/log;
import ballerina/sql;
import ballerinax/mysql;

listener http:Listener httpDefaultListener = http:getDefaultListener();

listener ftp:Listener salesDataService = new (protocol = ftp:SFTP, path = "/test-06032025/con-demo/salesdata", port = 22, auth = {
    credentials: {
        username: sftpUser,
        password: sftpPass
    }
}, fileNamePattern = "(.*).csv", host = "ftp.support.wso2.com", pollingInterval = 3);

service ftp:Service on salesDataService {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        do {
            log:printInfo(event.addedFiles.toJsonString());
            foreach ftp:FileInfo fileInfo in event.addedFiles {
                stream<byte[] & readonly, io:Error?> dataStream = check caller->get(fileInfo.pathDecoded);
                SalesData[] salesData = check csv:parseStream(dataStream);
                foreach SalesData sd in salesData {
                    sql:ExecutionResult sqlExecutionresult = check salesDB->execute(`INSERT INTO demo1.sales_data (shopId, custId, pid, quantity) VALUES (${sd.shopId}, ${sd.customer}, ${sd.product}, ${sd.quantity})`);
                }
            }
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

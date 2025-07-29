import ballerina/data.csv;
import ballerina/ftp;
import ballerina/io;
import ballerina/log;
import ballerina/sql;

listener ftp:Listener filesL = new (protocol = ftp:SFTP, host = sftpHost, port = 2222, auth = {
    credentials: {
        username: "foo",
        password: "pass"
    }
}, path = "/upload", fileNamePattern = "(.*).csv", pollingInterval = 3);

service ftp:Service on filesL {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        do {

            foreach ftp:FileInfo fileInfo in event.addedFiles {
                stream<byte[] & readonly, io:Error?> dataStream = check caller->get(fileInfo.pathDecoded);
                SalesRecord[] salesRecords = check csv:parseStream(dataStream);
                foreach SalesRecord sd in salesRecords {
                    log:printInfo(sd.shopId);
                    sql:ExecutionResult sqlExecutionresult = check salesDB->execute(`INSERT INTO salesDB.sales_data (shopId, customerId, productid, quantity) VALUES (${sd.shopId}, ${sd.customer}, ${sd.product}, ${sd.quantity})`);
                }
            }
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

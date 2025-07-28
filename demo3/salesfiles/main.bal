import ballerina/data.csv;
import ballerina/ftp;
import ballerina/io;
import ballerina/log;
import ballerina/sql;

listener ftp:Listener salesFilesL = new (protocol = ftp:SFTP, path = sftpPath, port = sftpPort, auth = {
    credentials: {
        username: sftpUser,
        password: sftpPass
    }
}, fileNamePattern = "(.*).csv", host = sftpHost, pollingInterval = 3);

service ftp:Service on salesFilesL {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        do {
            log:printInfo(event.addedFiles.toBalString());
            foreach ftp:FileInfo salesFileInfo in event.addedFiles {
                stream<byte[] & readonly, io:Error?> dataStream = check caller->get(salesFileInfo.pathDecoded);
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
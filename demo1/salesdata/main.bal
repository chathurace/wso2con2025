import ballerina/ftp;
import ballerina/http;
import ballerina/log;

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
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

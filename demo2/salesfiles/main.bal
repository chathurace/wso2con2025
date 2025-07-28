import ballerina/ftp;
import ballerina/log;

listener ftp:Listener salesSFTP = new (protocol = ftp:SFTP, path = sftpPath, port = sftpPort, auth = {
    credentials: {
        username: sftpUser,
        password: sftpPass
    }
}, fileNamePattern = "(.*).csv", host = sftpHost, pollingInterval = 3);

service ftp:Service on salesSFTP {
    remote function onFileChange(ftp:WatchEvent & readonly event, ftp:Caller caller) returns error? {
        do {
            log:printInfo(event.addedFiles.toBalString());
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

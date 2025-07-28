import ballerina/http;
import ballerina/log;

listener http:Listener httpDefaultListener = http:getDefaultListener();

service /test1 on httpDefaultListener {
    resource function get status() returns error|json|http:InternalServerError {
        do {
            log:printInfo("Test1.status invoked.");
            return {status: "OK", test1: "Devant"};
        } on fail error err {
            // handle error
            return error("unhandled error", err);
        }
    }
}

import ballerina/http;

@http:ServiceConfig {
    basePath: "/"
}

service noterService on new http:Listener(9090) {
    
    @http:ResourceConfig{
        path: "/hello",
        methods: ["POST"]
    }

    resource function hello(http:Caller caller, http:Request request) returns error? {
        http:Response res = new;
        json incomingJSON = check request.getJsonPayload();

        res.setJsonPayload("", contentType = "application/json");
        check caller -> respond(res);
    }
}
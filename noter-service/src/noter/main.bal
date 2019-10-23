import ballerina/crypto;
import ballerina/http;
import ballerina/lang.'int;
import ballerina/log;
import ballerina/docker;

int myPort = 9090; // change for every instance
string[] instance_ports = ["9090", "9091", "9092", "9093", "9094"];

map<json> ledger = {"data": "", "hash": "", "previous-hash": "", "height": 0};
// maybe use database in future
map<json> notices = {};
// use an address that can be accessed by all containers
// localhost refers to the container itself
string addressPart = "http://192.168.56.101:"; // change this according to machine ip

@docker:Expose {}
// change number to equal myPort variable for each instance run
listener http:Listener mylistener = new(9090);

@docker:Config {
    name: "notes0",
    tag: "v1.0"
}

@http:ServiceConfig {
    basePath: "/"
}

service noterService on mylistener {

    @http:ResourceConfig {
        path: "/addNotice",
        methods: ["POST"]
    }
    resource function addNotice(http:Caller caller, http:Request request) returns error? {
        http:Response res = new;
        json rawJSON = check request.getJsonPayload();
        map<json> renderedJson = check map<json>.constructFrom(rawJSON);
        // get the fields
        string id = renderedJson["id"].toString();
        string topic = renderedJson["topic"].toString();
        string description = renderedJson["description"].toString();
        int day = check 'int:fromString(renderedJson["day"].toString());
        int weekNumber = check 'int:fromString(renderedJson["weekNumber"].toString());
        int month = check 'int:fromString(renderedJson["month"].toString());
        string submissionDate = renderedJson["submissionDate"].toString();
        // don't accept if id is empty
        if(id == ""){
            check caller -> ok();
            return;
        }
        if(notices.hasKey(id)){
            res.statusCode = 400;
            res.setJsonPayload("Notice already exists", contentType = "application/json");
            check caller->respond(res);
        }else{
            // add notice to storage, adding to ledger, gossip
            json notice = {"id": id, "topic": topic, "description": description, "day": day, "weekNumber": weekNumber, "month": month, "submissionDate" : submissionDate};
            notices[id] = notice;

            string noticeHash = getSha512(notice.toString());
            ledger["data"] = notice;
            
            ledger["hash"] = noticeHash;
            int theHeight = check 'int:fromString(ledger["height"].toString());
            ledger["height"] = theHeight + 1;
            
            if(ledger["height"] == 1){
                // current becomes previous hash
                ledger["previous-hash"] = ledger["hash"];
                string h = getPreviousHash();
                log:printInfo(myPort.toString()+" Hash received: "+ h);
                if(h.length() == 0){
                    ledger["previous-hash"] = noticeHash;
                    log:printInfo("["+myPort.toString()+"] Using own hash");
                }else{
                    ledger["previous-hash"] = h;
                    log:printInfo("["+myPort.toString()+"] Using the received hash [height] "+ledger["height"].toString());
                }
            }
            log:printInfo("Notice id: "+id+" created on instance "+myPort.toString()+ " [height] "+ledger["height"].toString());
            // gossip to other instances
            gossip();
            // return the data received as is
            res.setJsonPayload(<@untainted>rawJSON, contentType = "application/json");
            check caller->respond(res);
        }
    }

    @http:ResourceConfig {
        path: "/getNotices",
        methods: ["GET"]
    }
    resource function getNotices(http:Caller caller, http:Request request) returns error?{
        http:Response res = new;
        json[] arr = requestAllNotices();
        json[] returnArr = [];

        foreach var n in notices {
            arr[arr.length()] = n;
        }
        foreach var a in arr {
            returnArr[returnArr.length()] = a;
        }

        res.setJsonPayload(<@untainted>returnArr, contentType = "application/json");
        check caller->respond(res);
    }

    @http:ResourceConfig {
        path: "/getNotice/{id}",
        methods: ["GET"]
    }
    resource function getNotice(http:Caller caller, http:Request request, string id) returns error?{
        http:Response res = new;
        if(notices.hasKey(id)){
            res.setJsonPayload(<@untainted>notices[id], contentType = "application/json");
        }else{
            // request from other instances
            json result = requestNotice(<@untainted>id);
            if(result == ""){
                res.setJsonPayload(<@untainted>"notice not found", contentType = "application/json");
            }else{
                res.setJsonPayload(<@untainted>result, contentType = "application/json");
            }
        }
        check caller->respond(res);
    }

    @http:ResourceConfig {
        path: "/internalFindNotice/{id}",
        methods: ["GET"]
    }
    resource function internalFindNotice(http:Caller caller, http:Request request, string id) returns error?{
        http:Response res = new;
        if(notices.hasKey(id)){
            res.setJsonPayload(<@untainted>notices[id], contentType = "application/json");
            check caller->respond(res);
        }else{
            check caller->ok();
        }
    }

    @http:ResourceConfig {
        path: "/internalDeleteNotice/{id}",
        methods: ["GET"]
    }
    resource function internalDeleteNotice(http:Caller caller, http:Request request, string id) returns error?{
        http:Response res = new;
        if(notices.hasKey(id)){
            json x = notices.remove(id);
            res.setJsonPayload(<@untainted>x, contentType = "application/json");
            check caller->respond(res);
        }else{
            res.setJsonPayload("notice not found", contentType = "application/json");
            check caller->respond(res);
        }
    }

    @http:ResourceConfig {
        path: "/internalAllNotices",
        methods: ["GET"]
    }
    resource function internalAllNotices(http:Caller caller, http:Request request) returns error?{
        http:Response res = new;
        json[] xyz = [];
        foreach var n in notices{
            xyz[xyz.length()] = n;
        }
        if(xyz.length() > 0){
            res.setJsonPayload(<@untainted>xyz, contentType = "application/json");
        check caller->respond(res);
        }else{
            check caller->ok();
        }
    }

    @http:ResourceConfig {
        path: "/updateNotice",
        methods: ["POST"]
    }
    resource function updateNotice(http:Caller caller, http:Request request) returns error? {
        http:Response res = new;
        json rawJSON = check request.getJsonPayload();
        map<json> renderedJson = check map<json>.constructFrom(rawJSON);
        // get the fields
        string id = renderedJson["id"].toString();
        string topic = renderedJson["topic"].toString();
        string description = renderedJson["description"].toString();
        var day = 'int:fromString(renderedJson["day"].toString());
        var weekNumber = 'int:fromString(renderedJson["weekNumber"].toString());
        var month = 'int:fromString(renderedJson["month"].toString());
        string submissionDate = renderedJson["submissionDate"].toString();
        
        // make sure id exists
        if(notices.hasKey(id)){
            // carry out update to fields which are not empty
            if(topic != ""){
                map<json> m = <map<json>> notices[id];
                m["topic"] = topic;
                notices[id] = checkpanic json.constructFrom(m);                
            }
            if(description != ""){
                map<json> m = <map<json>> notices[id];
                m["description"] = description;
                notices[id] = checkpanic json.constructFrom(m);  
            }
            if(submissionDate != ""){
                map<json> m = <map<json>> notices[id];
                m["submissionDate"] = submissionDate;
                notices[id] = checkpanic json.constructFrom(m);  
            }
            if(day is int){
                map<json> m = <map<json>> notices[id];
                m["day"] = day;
                notices[id] = checkpanic json.constructFrom(m);
            }
            if(weekNumber is int){
                map<json> m = <map<json>> notices[id];
                m["weekNumber"] = weekNumber;
                notices[id] = checkpanic json.constructFrom(m);
            }
            if(month is int){
                map<json> m = <map<json>> notices[id];
                m["month"] = month;
                notices[id] = checkpanic json.constructFrom(m);  
            }
            res.setJsonPayload(<@untainted>rawJSON, contentType = "application/json");
        }else {
            res.setJsonPayload("id not found", contentType = "application/json");
        }

        check caller->respond(res);
    }

    @http:ResourceConfig {
        path: "/deleteNotice/{id}",
        methods: ["GET"]
    }
    resource function deleteNotice(http:Caller caller, http:Request request, string id) returns error? {
        http:Response res = new;
        json rawJSON = check request.getJsonPayload();
        map<json> renderedJson = check map<json>.constructFrom(rawJSON);        
        // make sure id exists
        if(notices.hasKey(id)){
            json e = notices.remove(id);
            res.setJsonPayload(<@untainted>e, contentType = "application/json");
        }else{
            json response = deleteNotice(<@untainted>id);
            res.setJsonPayload(response, contentType = "application/json");
        }
        check caller->respond(res);
    }

    @http:ResourceConfig {
        methods: ["POST"],
        path: "/validate"
    }

    resource function validate(http:Caller caller, http:Request req) returns error? {
        json jsonValue = checkpanic req.getJsonPayload();
        map<json> renderedJson = check map<json>.constructFrom(jsonValue);
        // The validation entails checking the hash of the previous ledger and the signature of
        // the current one
        if( ledger["hash"] == "" || (renderedJson["previous-hash"] == ledger["hash"])){
            ledger["previous-hash"] = ledger["hash"];
            ledger["data"] = renderedJson["data"];
            ledger["hash"] = renderedJson["hash"];
            ledger["height"] = check 'int:fromString(ledger["height"].toString()) + 1;
            log:printInfo("["+myPort.toString()+"] ledger accepted [height] "+ledger["height"].toString());
        }else{
            log:printInfo("["+myPort.toString()+"] ledger not accepted [height] "+ledger["height"].toString());
        }
        check caller -> ok();
    }

    @http:ResourceConfig {
        path: "/internalGetHeight",
        methods: ["GET"]
    }
    resource function internalGetHeight(http:Caller caller, http:Request request) returns error?{
        http:Response res = new;
        res.setTextPayload(<@untainted>ledger["height"].toString());
        check caller->respond(res);
    }

    @http:ResourceConfig {
        path: "/internalGetPreviousHash",
        methods: ["GET"]
    }
    resource function internalGetPreviousHash(http:Caller caller, http:Request request){
        http:Response res = new;
        res.setTextPayload(<@untainted>ledger["previous-hash"].toString());
        var result = caller->respond(res);
    }
} // service end

function getSha512(string data) returns string {
    byte[] output = crypto:hashSha512(data.toBytes());
    return output.toString();
}

function gossip() {
    foreach string p in instance_ports {
        if(p != myPort.toString()){
            http:Client clientEP = new (addressPart + p);
            var response = clientEP->post("/validate", <@untainted>ledger);
        }
    }
}

function requestNotice(string id) returns json{
    foreach string p in instance_ports {
        if(p != myPort.toString()){
            http:Client clientEP = new (addressPart + p);
            var response = clientEP->get("/internalFindNotice/"+id);
            if(response is http:Response){
                var x = response.getJsonPayload();
                if(x is json && x != "notice not found"){
                    return <@untainted>x;
                }
            }
        }
    }
    return "";
}

function requestAllNotices() returns json[]{
    json[] m = [];
    
    foreach string p in instance_ports {
        if(p != myPort.toString()){
            http:Client clientEP = new (addressPart + p);
            var response = clientEP->get("/internalAllNotices");
            if(response is http:Response){
                var x = response.getJsonPayload();
                if(x is json[]){
                    foreach var n in x{
                        m[m.length()] = n;
                    }
                }
            }
        }
    }
    return <@untainted>m;
}

# Finds instance with greatest height and retrieve it's previous hash
#
# + return - previous hash
function getPreviousHash() returns string{
    string address = "";
    int highest = -1;
    foreach string p in instance_ports {
        if(p != myPort.toString()){
            http:Client clientEP = new (addressPart + p);
            var response = clientEP->get("/internalGetHeight");
            if(response is http:Response){
                var txt = response.getTextPayload();
                if(txt is string){
                    int|error i = 'int:fromString(txt);
                    if(i is int){
                        if(i > highest){
                            highest = i;
                            address = p;
                        }
                    }
                }
            }
        }
    }
    // greater than 1 <- our current height
    if(highest > 1){
        http:Client clientEP = new (address);
        var response = clientEP->get("/internalGetPreviousHash");
        if(response is http:Response){
            var txt = response.getTextPayload();
            if(txt is string){
                log:printInfo("hash from "+address+" height: "+highest.toString());
                return <@untainted>txt;
            }
        }
    }

    return "";
}

function deleteNotice(string id) returns json{
    foreach string p in instance_ports {
        if(p != myPort.toString()){
            http:Client clientEP = new (addressPart + p);
            var response = clientEP->get("/internalDeleteNotice/"+id);
            if(response is http:Response){
                var x = response.getJsonPayload();
                if(x is json && x != "notice not found"){
                    return <@untainted>x;
                }
            }
        }
    }
    return "notice not found";
}

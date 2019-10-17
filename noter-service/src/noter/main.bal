import ballerina/http;
import ballerina/lang.'int;
import ballerina/crypto;

string[] instance_ports = ["9091", "9092", "9093", "9094"];
map<json> ledger = {"data": "", "hash": "", "previous-hash": ""};
// maybe use database in future
map<json> notices = {};

@http:ServiceConfig {
    basePath: "/"
}

service noterService on new http:Listener(9090) {
    
    @http:ResourceConfig{
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

        // add notice to storage, adding to ledger, gossip
        json notice = {"id": id, "topic": topic, "description": description, "day": day, "weekNumber": weekNumber, "month": month};
        notices[id] = notice;
        
        string noticeHash = getSha512(notice.toString());
        ledger["data"] = notice;
        ledger["hash"] = noticeHash;
        // no need to touch 'previous-hash'

        // gossip to other instances

        res.setJsonPayload(<@untainted> rawJSON, contentType = "application/json");
        check caller -> respond(res);
    }
}

function getSha512(string data) returns string{
    byte[] output = crypto:hashSha512(data.toBytes());
    return output.toString();
}

function gossip() {
    foreach string p in instance_ports {
        http:Client clientEP = new("http://localhost:"+p+"/");
        var response = clientEP->post("/validate", ledger);
    }
}
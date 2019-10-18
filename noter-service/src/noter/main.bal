import ballerina/crypto;
import ballerina/http;
import ballerina/lang.'int as ints;
import ballerina/io;
// import ballerina/log;

int myPort = 9091; // change for every instance
// something more elegant may be needed here
string[] instance_ports = ["9091", "9092", "9093", "9094","9095"];

json ledger = {"data": "", "hash": "", "previous-hash": ""};
// maybe use database in future
json[] notices1 = [
    {"id": 1, 
    "topic": "server", 
    "description": "Ballerina server", 
    "day": 5, 
    "week": 2, 
    "month": 1,
    "submissionDate": "13/10/2019"
    },
    {"id": 2, 
    "topic": "secind test", 
    "description": "Ballerina server test", 
    "day": 5, 
    "week": 2, 
    "month": 1,
    "submissionDate": "13/10/2019"
    }
];
json[] notices2 = [
    {"id": 1, 
    "topic": "server", 
    "description": "Ballerina server", 
    "day": 5, 
    "week": 2, 
    "month": 1,
    "submissionDate": "13/10/2019"
    },
    {"id": 2, 
    "topic": "secind test", 
    "description": "Ballerina server test", 
    "day": 5, 
    "week": 2, 
    "month": 1,
    "submissionDate": "13/10/2019"
    }
];
json[] notices3 = [
    {"id": 1, 
    "topic": "server", 
    "description": "Ballerina server", 
    "day": 5, 
    "week": 2, 
    "month": 1,
    "submissionDate": "13/10/2019"
    },
    {"id": 2, 
    "topic": "secind test", 
    "description": "Ballerina server test", 
    "day": 5, 
    "week": 2, 
    "month": 1,
    "submissionDate": "13/10/2019"
    }
];
json[] notices4 = [
    {"id": 1, 
    "topic": "server", 
    "description": "Ballerina server", 
    "day": 5, 
    "week": 2, 
    "month": 1,
    "submissionDate": "13/10/2019"
    },
    {"id": 2, 
    "topic": "secind test", 
    "description": "Ballerina server test", 
    "day": 5, 
    "week": 2, 
    "month": 1,
    "submissionDate": "13/10/2019"
    }
];
json[] notices5 = [
    {"id": 1, 
    "topic": "server", 
    "description": "Ballerina server", 
    "day": 5, 
    "week": 2, 
    "month": 1,
    "submissionDate": "13/10/2019"
    },
    {"id": 2, 
    "topic": "secind test", 
    "description": "Ballerina server test", 
    "day": 5, 
    "week": 2, 
    "month": 1,
    "submissionDate": "13/10/2019"
    }
];
listener http:Listener port1 = new(9091);
listener http:Listener port2 = new(9092);
listener http:Listener port3 = new(9093);
listener http:Listener port4 = new(9094);
listener http:Listener port5 = new(9095);
int count = 0;
int ledgerCount = 0;
@http:ServiceConfig {
    basePath: "/"
}

service noterService on port1, port2, port3, port4, port5{
    @http:ResourceConfig {
        path: "/addNotice",
        methods: ["POST"]
    }

    // not tested
    resource function addNotice(http:Caller caller, http:Request request) returns error? {
        io:print(request);
        http:Response res = new;
        json rawJSON = check request.getJsonPayload();
        io:print(rawJSON);
        // map<json> renderedJson = check map<json>.constructFrom(rawJSON);
        // get the fields
        // string id = renderedJson["id"].toString();
        // string topic = renderedJson["topic"].toString();
        // string description = renderedJson["description"].toString();
        // int day = check 'int:fromString(renderedJson["day"].toString());
        // int weekNumber = check 'int:fromString(renderedJson["weekNumber"].toString());
        // int month = check 'int:fromString(renderedJson["month"].toString());

        // add notice to storage, adding to ledger, gossip
        // json notice = {"id": id, "topic": topic, "description": description, "day": day, "weekNumber": weekNumber, "month": month};
        string lastIndex = notices1[notices1.length() - 1].id.toString();
        int|error lIndex = ints:fromString(lastIndex);

        if(lIndex is int){
            json index = {"id": lIndex+1};
            json|error notice = rawJSON.mergeJson(index);

            if(notice is json){
                int port = caller.localAddress.port;
                if(port == 9091){
                    json ledger1 = ledgerHandle(notice);
                    boolean valid = validate(ledger1);
                    if(valid){
                        notices1.push(notice);
                        if(ledger1.ledgerCount == 5){
                            ledgerCount = 0;
                            ledger = <@untainted>ledger1;
                            res.setJsonPayload(<@untainted>notice, contentType = "application/json");
                            check caller->respond(res);  
                        }
                        else{
                            gossip(instance_ports[1],notice);
                        }
                        
                    }
                }
                else if (port == 9092){
                    json ledger2 = ledgerHandle(notice);
                    boolean valid = validate(ledger2);
                    if(valid){
                        notices2.push(notice);
                        if(ledger2.ledgerCount == 5){
                            ledgerCount = 0;
                            res.setJsonPayload(<@untainted>notice, contentType = "application/json");
                            check caller->respond(res);  
                        }
                        else{
                            gossip(instance_ports[2],notice);
                        }  
                    }
                }
                else if (port == 9093){
                    json ledger3 = ledgerHandle(notice);
                    boolean valid = validate(ledger3);
                    if(valid){
                        notices3.push(notice);
                        if(ledger3.ledgerCount == 5){
                            ledgerCount = 0;
                            res.setJsonPayload(<@untainted>notice, contentType = "application/json");
                            check caller->respond(res);  
                        }
                        else{
                            gossip(instance_ports[3],notice);
                        }  
                    }                   
                }
                else if (port == 9094){
                    json ledger4 = ledgerHandle(notice);
                    boolean valid = validate(ledger4);
                    if(valid){
                        notices4.push(notice);
                        if(ledger4.ledgerCount == 5){
                            ledgerCount = 0;
                            res.setJsonPayload(<@untainted>notice, contentType = "application/json");
                            check caller->respond(res);  
                        }
                        else{
                            gossip(instance_ports[4],notice);
                        }  
                    }
                }
                else if (port == 9095){
                    json ledger5 = ledgerHandle(notice);
                    boolean valid = validate(ledger5);
                    if(valid){
                        notices5.push(notice);
                        if(ledger5.ledgerCount == 5){
                            ledgerCount = 0;
                            res.setJsonPayload(<@untainted>notice, contentType = "application/json");
                            check caller->respond(res);  
                        }
                        else{
                            gossip(instance_ports[0],notice);
                        }  
                    }
                }
            }
        }
              

        // string noticeHash = getSha512(rawJSON.toJsonString());
        // ledger["data"] = rawJSON;
        // // current becomes previous hash
        // if(ledger["height"] != 0){
        //     ledger["previous-hash"] = ledger["hash"];
        // }
        // ledger["hash"] = noticeHash;
        // count = count + 1;
        // ledger["height"] = count;
        // // no need to touch 'previous-hash'
        // // gossip to other instances
        // gossip();
        // // return the data received as is
        // res.setJsonPayload(<@untainted>rawJSON, contentType = "application/json");
        // check caller->respond(res);
    }

    @http:ResourceConfig {
        path: "/getNotices",
        methods: ["GET"]
    }
    // tested, and working
    resource function getNotices(http:Caller caller, http:Request request) returns error?{
        http:Response res = new;
        int port = caller.localAddress.port;
        if(port == 9091){
            res.setJsonPayload(<@untainted>notices1, contentType = "application/json");
            check caller->respond(res);
        }
        else if (port == 9092){
            res.setJsonPayload(<@untainted>notices2, contentType = "application/json");
            check caller->respond(res);
        }
        else if (port == 9093){
            res.setJsonPayload(<@untainted>notices3, contentType = "application/json");
            check caller->respond(res);
        }
        else if (port == 9094){
            res.setJsonPayload(<@untainted>notices4, contentType = "application/json");
            check caller->respond(res);
        }
        else if (port == 9095){
            res.setJsonPayload(<@untainted>notices5, contentType = "application/json");
            check caller->respond(res);
        }   
    }

    @http:ResourceConfig {
        path: "/getNotice/{id}",
        methods: ["GET"]
    }
    // tested and working
    resource function getNotice(http:Caller caller, http:Request request, int id) returns error?{
        http:Response res = new;
        json err = {"error": "Notice not found"};
        int port = caller.localAddress.port;
        if(port == 9091){
            foreach var notice in notices1 {
                if(notice.id == id){
                    res.setJsonPayload(<@untainted>notice, contentType = "application/json");
                    check caller->respond(res);
                }
            }
        }
        else if (port == 9092){
            foreach var notice in notices2 {
                if(notice.id == id){
                    res.setJsonPayload(<@untainted>notice, contentType = "application/json");
                    check caller->respond(res);
                }
            }
        }
        else if (port == 9093){
            foreach var notice in notices3 {
                if(notice.id == id){
                    res.setJsonPayload(<@untainted>notice, contentType = "application/json");
                    check caller->respond(res);
                }
            }
        }
        else if (port == 9094){
            foreach var notice in notices4 {
                if(notice.id == id){
                    res.setJsonPayload(<@untainted>notice, contentType = "application/json");
                    check caller->respond(res);
                }
            }
        }
        else if (port == 9095){
            foreach var notice in notices5 {
                if(notice.id == id){
                    res.setJsonPayload(<@untainted>notice, contentType = "application/json");
                    check caller->respond(res);
                }
            }
        }
        res.setJsonPayload(<@untainted>err, contentType = "application/json");
        check caller->respond(res);
        
    }

    // @http:ResourceConfig {
    //     path: "/updateNotice",
    //     methods: ["POST"]
    // }
    // // not tested
    // resource function updateNotice(http:Caller caller, http:Request request) returns error? {
    //     http:Response res = new;
    //     json rawJSON = check request.getJsonPayload();
    //     map<json> renderedJson = check map<json>.constructFrom(rawJSON);
    //     // get the fields
    //     string id = renderedJson["id"].toString();
    //     string topic = renderedJson["topic"].toString();
    //     string description = renderedJson["description"].toString();
    //     var day = 'int:fromString(renderedJson["day"].toString());
    //     var weekNumber = 'int:fromString(renderedJson["weekNumber"].toString());
    //     var month = 'int:fromString(renderedJson["month"].toString());
    //     // make sure id exists
    //     if(notices.hasKey(id)){
    //         // carry out update to fields which are not empty
    //         if(topic != ""){
    //             map<json> m = <map<json>> notices[id];
    //             m["topic"] = topic;
    //             notices[id] = checkpanic json.constructFrom(m);                
    //         }
    //         if(description != ""){
    //             map<json> m = <map<json>> notices[id];
    //             m["description"] = description;
    //             notices[id] = checkpanic json.constructFrom(m);  
    //         }
    //         if(day is int){
    //             map<json> m = <map<json>> notices[id];
    //             m["day"] = day;
    //             notices[id] = checkpanic json.constructFrom(m);
    //         }
    //         if(weekNumber is int){
    //             map<json> m = <map<json>> notices[id];
    //             m["weekNumber"] = weekNumber;
    //             notices[id] = checkpanic json.constructFrom(m);
    //         }
    //         if(month is int){
    //             map<json> m = <map<json>> notices[id];
    //             m["month"] = month;
    //             notices[id] = checkpanic json.constructFrom(m);  
    //         }
    //     }

    //     res.setJsonPayload(<@untainted>rawJSON, contentType = "application/json");
    //     check caller->respond(res);
    // }

    // @http:ResourceConfig {
    //     path: "/deleteNotice",
    //     methods: ["POST"]
    // }
    // // not tested
    // resource function deleteNotice(http:Caller caller, http:Request request) returns error? {
    //     http:Response res = new;
    //     json rawJSON = check request.getJsonPayload();
    //     // map<json> renderedJson = check map<json>.constructFrom(rawJSON);
    //     // get the fields
    //     //string id = renderedJson["id"].toString();
 
    //     // make sure id exists
    //     if(notices.hasKey(id)){
    //         var e = notices.remove(id);
    //         res.setJsonPayload(<@untainted>"delete successful", contentType = "application/json");
    //     }else{
    //         res.setJsonPayload(<@untainted>"key not found", contentType = "application/json");
    //     }
    //     check caller->respond(res);
    // }

    // @http:ResourceConfig {
    //     methods: ["POST"],
    //     path: "/validate"
    // }

    // // not tested
    // resource function validate(http:Caller caller, http:Request req) returns error? {
    //     json jsonValue = checkpanic req.getJsonPayload();
    //     map<json> renderedJson = check map<json>.constructFrom(jsonValue);
    //     // The validation entails checking the hash of the previous ledger and the signature of
    //     // the current one
    //     // check if is genesis to us
    //     if(ledger["height"] == 0){
    //         // since we have nothing to compare with, just accept
    //         ledger["data"] = renderedJson["data"];
    //         ledger["hash"] = renderedJson["hash"];
    //         ledger["height"] = check 'int:fromString(ledger["height"].toString()) + 1;
    //         log:printInfo("ledger accepted as genesis");
    //     }else if(renderedJson["previous-hash"] == ledger["hash"]){
    //         ledger["previous-hash"] = ledger["hash"];
    //         ledger["data"] = renderedJson["data"];
    //         ledger["hash"] = renderedJson["hash"];
    //         ledger["height"] = check 'int:fromString(ledger["height"].toString()) + 1;
    //         log:printInfo("ledger accepted");
    //     }else{
    //         log:printInfo("ledger not accepted");
    //     }
    //     var x = caller -> ok();
    // }
}

function getSha512(string data) returns string {
    byte[] output = crypto:hashSha512(data.toBytes());
    return output.toString();
}

function ledgerHandle(json notice) returns json{
    ledgerCount = ledgerCount+ 1;
    json currentLedger = {
        "data": notice,
        "hash": getSha512(notice.toJsonString()),
        "previousHash": ledger.hash.toString(),
        "count": ledgerCount
    };
    io:println("\n\nledger count: ",ledgerCount);
    return currentLedger;
}

function validate(json currentLedger) returns boolean{
    if(currentLedger.previousHash == ledger.hash){
        return true;
    }
    return false;
}

// not tested
function gossip(string port, json notice) {
    http:Client clientEP = new ("http://localhost:" + port + "/");
    var response = clientEP->post("/addNotice", <@untainted>notice);
}

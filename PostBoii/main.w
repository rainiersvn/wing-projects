bring cloud;
bring http;

bring "./postBoii.w" as postBoii;
bring "./structs.w" as structs;

let postBoiiHandler = new postBoii.PostBoii("cloudkid-emails-wing");
let postBoiiApi = new cloud.Api();

class Utils {
    extern "./util/util.js" static inflight extractJson(json: Json, key: str): str;
    init() { }
}

postBoiiApi.post("/subscribeEmail", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    try {
        if let body = request.body {
            let email = Utils.extractJson(body, "email");
            log("Email to subscribe: ${email}");
            let response = postBoiiHandler.subscribeEmail(email);
    
            return {
                status: 201,
                body: response
            };
        }
    } catch err {
        log("Error during email subscription: ${err}");
        return {
            status: 500,
            body: "There was an error"
        };
    }
});

postBoiiApi.post("/queueEmail", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    try {
        if let body = request.body {
            log("Incoming email payload: ${body}");
            
            let payload: Json = Json.parse(body);
            postBoiiHandler.queueEmail(payload);

            return {
                status: 200,
                body: "Email has been sent"
            };
        }
    } catch err {
        log("Error during email queueing: ${err}");
        return {
            status: 500,
            body: "There was an error sending the email"
        };
    }
});

postBoiiApi.post("/unsubscribeEmail", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    try {
        if let body = request.body {
            log("Incoming unsubscribe email payload: ${body}");
            let response = postBoiiHandler.unsubscribeEmail(Json.parse(body));
            return {
                status: 204,
                body: response
            };
        }
    } catch err {
        log("Error during email unsubscription: ${err}");
        return {
            status: 500,
            body: "There was an error"
        };
    }
});

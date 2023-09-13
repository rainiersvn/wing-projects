bring cloud;
bring http;
bring "./postBoii.w" as postBoii;

let sendEmail = inflight (msg: str): void => {
    try {
        log("SEND EMAIL MSG: ${msg}");
    } catch err {
        log("Error during email queueing: ${err}");
    }
};

let postBoiiHandler = new postBoii.PostBoii("cloudkid-emails-wing");

let postBoiiApi = new cloud.Api();

class Utils {
    extern "./util/util.js" static inflight extractJson(json: Json, key: str): str;
    init() { }
}

postBoiiApi.post("/subscribeEmail", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    if let body = request.body {
        let email = Utils.extractJson(body, "email");
        log("Email to subscribe: ${email}");
        let response = postBoiiHandler.subscribeEmail(email);

        return {
            status: 201,
            body: response
        };
    }
});

postBoiiApi.post("/queueEmail", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    if let body = request.body {
        postBoiiHandler.queueEmail(Json.parse(body));
        return {
            status: 201,
            body: request.body
        };
    }
});

postBoiiApi.post("/unsubscribeEmail", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    if let body = request.body {
        let response = postBoiiHandler.unsubscribeEmail(Json.parse(body));
        return {
            status: 204,
            body: response
        };
    }
});

test "queue email" {
    let payload = postBoii.Payload {
        message: "how are you dude?",
        subject: "hello, world!",
        to: "ping@wing.cloud"
    };

    http.post("${postBoiiApi.url}/queueEmail", body: Json.stringify(payload));
}
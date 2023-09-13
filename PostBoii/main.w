bring cloud;
bring "./postBoii.w" as postBoii;
bring "./structs.w" as structs;

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

        return cloud.ApiResponse {
            status: 201,
            body: response
        };
    }
});

postBoiiApi.post("/queueEmail", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    if let body = request.body {
        log("BODY -> ${body}");
        
        // let emailData = structs.SendEmail.fromJson(body);
        let emailData: Json = Json.parse(body);
        log("emailData -> ${emailData}");

        let emailTemplate = {
            Destination: {
                ToAddresses: emailData.get("to")
            },
            Message: {
                Body: {
                    Html: {
                        Charset: "UTF-8",
                        Data: emailData.get("message")
                    }
                },
                Subject: {
                    Charset: "UTF-8",
                    Data: emailData.get("subject")
                }
            },
            Source: "notifications@cloudkid.lin",
            ReplyToAddresses: [
                "info@cloudkid.link",
            ],
        };
        log("emailData -> ${emailTemplate}");
        // log("Email to queue: ${emailTemplate}");
        postBoiiHandler.queueEmail(emailTemplate);
        return cloud.ApiResponse {
            status: 201,
            body: request.body
        };
    }
});

postBoiiApi.post("/unsubscribeEmail", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    if let body = request.body {
        let response = postBoiiHandler.unsubscribeEmail(Json.parse(body));
        return cloud.ApiResponse {
            status: 204,
            body: response
        };
    }
});

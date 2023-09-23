bring cloud;
bring http;
bring aws;

bring "./MailMan.w" as MailMan;
bring "./structs.w" as structs;

let MailManHandler = new MailMan.MailMan("cloudkid-emails-wing") as "MailManHandler";
let MailManApi = new cloud.Api() as "MailMan";

let _sendEmail = new cloud.Function(inflight (emailPayload: str) => {
    log("Sending email payload ${emailPayload}");
    let sendEmailReceipt = Utils.sendEmail(Json.parse(emailPayload));
    MailManHandler.saveEmailReceipt(Json.parse(emailPayload), sendEmailReceipt);
});

if let lambda = aws.Function.from(_sendEmail) {
    lambda.addPolicyStatements([
        aws.PolicyStatement {
            actions: ["ses:sendEmail"],
            effect: aws.Effect.ALLOW,
            resources: ["*"],
        },
    ]);
}

class Utils {
    // extern "./util/util.js" static inflight extractJson(json: Json, key: str): str;
    extern "./util/sendEmail.ts" static inflight sendEmail(payload: Json): Json;
    init() { }
}

MailManHandler.setConsumer(inflight (email) => {
    _sendEmail.invoke(email);
});

MailManApi.post("/subscribeEmail", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    try {
        if let body = request.body {
            // let email = Utils.extractJson(body, "email");
            log("Email to subscribe: ${body}");
            let response = MailManHandler.subscribeEmail(body);
            if response == true {
                return {
                    status: 201,
                    body: "Success"
                };
            } else {
                return {
                    status: 500,
                    body: "Failure to subscribe"
                };
            }
        }
    } catch err {
        log("Error during email subscription: ${err}");
        return {
            status: 500,
            body: "There was an error"
        };
    }
});

MailManApi.post("/queueEmail", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    try {
        if let body = request.body {
            log("Incoming email payload: ${body}");
            
            let payload: Json = Json.parse(body);
            MailManHandler.queueEmail(payload);

            return {
                status: 201,
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

MailManApi.post("/unsubscribeEmail", inflight (request: cloud.ApiRequest): cloud.ApiResponse => {
    try {
        if let body = request.body {
            log("Incoming unsubscribe email payload: ${body}");
            let response = MailManHandler.unsubscribeEmail(Json.parse(body));
            return {
                status: 201,
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

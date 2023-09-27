bring cloud;
bring http;
bring aws;

bring "./mailMan.w" as mailMan;
bring "./structs.w" as structs;

let mailManHandler = new mailMan.MailMan("cloudkid-emails-wing") as "MailManHandler";
let mailManApi = new cloud.Api() as "MailMan";

let sendEmail = new cloud.Function(inflight (emailPayload: str) => {
    log("Sending email payload ${emailPayload}");
    let sendEmailReceipt = Utils.sendEmail(Json.parse(emailPayload));
    mailManHandler.saveEmailReceipt(Json.parse(emailPayload), sendEmailReceipt);
});

if let lambda = aws.Function.from(sendEmail) {
    lambda.addPolicyStatements([
        aws.PolicyStatement {
            actions: ["ses:sendEmail"],
            effect: aws.Effect.ALLOW,
            resources: ["*"],
        },
    ]);
}

class Utils {
    extern "./util/sendEmail.ts" pub static inflight sendEmail(payload: Json): Json;
}

mailManHandler.setConsumer(inflight (email) => {
    sendEmail.invoke(email);
});

mailManApi.post("/subscribeEmail", inflight (request) => {
    try {
        if let body = request.body {
            log("Email to subscribe: ${body}");
            if mailManHandler.subscribeEmail(body) {
                return { status: 201, body: "Success" };
            } else {
                return { status: 500, body: "Failure to subscribe" };
            }
        }
    } catch err {
        log("Error during email subscription: ${err}");
        return { status: 500, body: "There was an error" };
    }
});

mailManApi.post("/queueEmail", inflight (request) => {
    try {
        if let body = request.body {
            log("Incoming email payload: ${body}");
            
            let payload = Json.parse(body);
            mailManHandler.queueEmail(payload);

            return { status: 201, body: "Email has been sent" };
        }
    } catch err {
        log("Error during email queueing: ${err}");
        return { status: 500, body: "There was an error sending the email" };
    }
});

mailManApi.post("/unsubscribeEmail", inflight (request) => {
    try {
        if let body = request.body {
            log("Incoming unsubscribe email payload: ${body}");
            let response = mailManHandler.unsubscribeEmail(Json.parse(body));
            return { status: 201, body: response };
        }
    } catch err {
        log("Error during email unsubscription: ${err}");
        return { status: 500, body: "There was an error" };
    }
});

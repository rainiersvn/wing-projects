bring cloud;
bring ex;

struct Payload {
    to: str;
    message: str;
    subject: str;
}

class PostBoii  {
    ck_postboii_emails: ex.Table;
    emailQueue: cloud.Queue;

    extern "./util/util.js" static inflight randomUUID(): str;
    extern "./util/util.js" static inflight createdDate(): str;
    extern "./util/util.js" static inflight extractJson(json: Json, key: str): str;
    extern "./util/sendEmail.js" static inflight sendEmail(payload: Json): str;
    
    init(tableName: str) {
        this.emailQueue = new cloud.Queue();
        this.ck_postboii_emails = new ex.Table(
            name: tableName,
            primaryKey: "email",
            columns: {
                emailUUID: ex.ColumnType.STRING,
                createdDate: ex.ColumnType.STRING
            }
        );
        // This is the sendEmail functionality
        this.emailQueue.setConsumer(inflight (email: str) => {
            try {
                log("Sending email...");
                PostBoii.sendEmail(email);
            } catch err {
                log("Error during email sending: ${err}");
            }
        } );
    }
    
    inflight subscribeEmail(email: str): str {
        try {

            let emailUUID = PostBoii.randomUUID();
            let createdDate = PostBoii.createdDate();

            this.ck_postboii_emails.insert(email, {
                "emailUUID": emailUUID,
                "createdDate": createdDate
            });

            return "Success";
        } catch err {
            log("Error during email subscription: ${err}");
            return "Failure";
        } finally {
            log("Email subscribed");
        }
    }

    inflight queueEmail(payload: Json) {
        try {
            let emailTemplate = {
                Destination: {
                    ToAddresses: [payload.get("to")]
                },
                Message: {
                    Body: {
                        Html: {
                            Charset: "UTF-8",
                            Data: payload.get("message")
                        }
                    },
                    Subject: {
                        Charset: "UTF-8",
                        Data: payload.get("subject")
                    }
                },
                Source: "notifications@cloudkid.link",
                ReplyToAddresses: [
                    "info@cloudkid.link",
                ],
            };

            log("Queuing email template: ${emailTemplate}");
            this.emailQueue.push(emailTemplate);
        } catch err {
            log("Error during email queueing: ${err}");
        }
    }
    
    inflight unsubscribeEmail(messageJson: Json): str {
        try {
            let emailToUnsub = messageJson.get("email");
            this.ck_postboii_emails.delete(str.fromJson(emailToUnsub));
            log("Email unsubscribed: ${emailToUnsub}");
            return "Unsubscribed";
        } catch err {
            log("Error during email queueing: ${err}");
            return "There was an error unsubscribing the email";
        }
    }
}
  
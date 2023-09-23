bring cloud;
bring ex;

struct Payload {
    to: str;
    message: str;
    subject: str;
}

class MailMan  {
    ck_mailman_emails: ex.Table;
    ck_mailman_emails_receipts: ex.Table;
    emailQueue: cloud.Queue;

    extern "./util/util.js" static inflight randomUUID(): str;
    extern "./util/util.js" static inflight createdDate(): str;

    init(tableName: str) {
        this.emailQueue = new cloud.Queue() as "MailMan-EmailQueue";
        this.ck_mailman_emails = new ex.Table(
            name: tableName,
            primaryKey: "email",
            columns: {
                emailUUID: ex.ColumnType.STRING,
                createdDate: ex.ColumnType.STRING
            }
        ) as "MailMan-Emails";

        this.ck_mailman_emails_receipts = new ex.Table(
            name: tableName,
            primaryKey: "receipt-email",
            columns: {
                email: ex.ColumnType.STRING,
                emailReceipt: ex.ColumnType.JSON,
                createdDate: ex.ColumnType.STRING
            }
        ) as "MailManEmail-Receipts";
    }
    
    setConsumer(fn: inflight (str): str) {
        this.emailQueue.setConsumer(fn);
    }

    inflight saveEmailReceipt(emailPayload: Json, emailReceiptData: Json): bool {
        try {
            let createdDate = MailMan.createdDate();
            let email = str.fromJson(emailPayload.get("Destination").get("ToAddresses").tryGetAt(0));
            log("Saving email receipt for email: ${email} with createdDate: ${createdDate}");
            this.ck_mailman_emails_receipts.insert(email, {
                "emailReceipt": emailReceiptData,
                "createdDate": createdDate
            });

            return true;
        } catch err {
            log("Error during email receipt saving: ${err}");
            return false;
        } finally {
            log("Email receipt saved");
        }
    }
    
    inflight subscribeEmail(emailPayload: Json): bool {
        try {
            let emailUUID = MailMan.randomUUID();
            let createdDate = MailMan.createdDate();
            let email = str.fromJson(emailPayload.get("email"));
            log("Subscribing email: ${email} with UUID: ${emailUUID} and createdDate: ${createdDate}");
            this.ck_mailman_emails.insert(email, {
                "emailUUID": emailUUID,
                "createdDate": createdDate
            });

            return true;
        } catch err {
            log("Error during email subscription: ${err}");
            return false;
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

            log("Queuing email template: ${Json.stringify(emailTemplate)}");
            this.emailQueue.push(Json.stringify(emailTemplate));
        } catch err {
            log("Error during email queueing: ${err}");
        }
    }
    
    inflight unsubscribeEmail(messageJson: Json): str {
        try {
            let emailToUnsub = messageJson.get("email");
            this.ck_mailman_emails.delete(str.fromJson(emailToUnsub));
            log("Email unsubscribed: ${emailToUnsub}");
            return "Unsubscribed";
        } catch err {
            log("Error during email queueing: ${err}");
            return "There was an error unsubscribing the email";
        }
    }
}
  
bring cloud;
bring ex;
bring util;

struct Payload {
    to: str;
    message: str;
    subject: str;
}

class MailMan  {
    emailsTable: ex.Table;
    emailsTableReceipts: ex.Table;
    emailQueue: cloud.Queue;

    init(tableName: str) {
        this.emailQueue = new cloud.Queue() as "MailMan-EmailQueue";
        this.emailsTable = new ex.Table(
            name: tableName,
            primaryKey: "email",
            columns: {
                emailUUID: ex.ColumnType.STRING,
                createdDate: ex.ColumnType.STRING
            }
        ) as "MailMan-Emails";

        this.emailsTableReceipts = new ex.Table(
            name: tableName,
            primaryKey: "receipt-email",
            columns: {
                email: ex.ColumnType.STRING,
                emailReceipt: ex.ColumnType.JSON,
                createdDate: ex.ColumnType.STRING
            }
        ) as "MailManEmail-Receipts";
    }
    
    pub setConsumer(fn: inflight (str): str) {
        this.emailQueue.setConsumer(fn);
    }

    pub inflight saveEmailReceipt(emailPayload: Json, emailReceiptData: Json): bool {
        try {
            let createdDate = std.Datetime.utcNow().toIso();
            let email = str.fromJson(emailPayload.get("Destination").get("ToAddresses").tryGetAt(0));
            log("Saving email receipt for email: ${email} with createdDate: ${createdDate}");
            this.emailsTableReceipts.insert(email, {
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
    
    pub inflight subscribeEmail(emailPayload: Json): bool {
        try {
            let emailUUID = util.uuidv4();
            let createdDate = std.Datetime.utcNow().toIso();
            let email = str.fromJson(emailPayload.get("email"));
            log("Subscribing email: ${email} with UUID: ${emailUUID} and createdDate: ${createdDate}");
            this.emailsTable.insert(email, {
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

    pub inflight queueEmail(payload: Json) {
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
    
    pub inflight unsubscribeEmail(messageJson: Json): str {
        try {
            let emailToUnsub = messageJson.get("email");
            this.emailsTable.delete(str.fromJson(emailToUnsub));
            log("Email unsubscribed: ${emailToUnsub}");
            return "Unsubscribed";
        } catch err {
            log("Error during email queueing: ${err}");
            return "There was an error unsubscribing the email";
        }
    }
}
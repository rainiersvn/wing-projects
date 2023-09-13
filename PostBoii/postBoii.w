bring cloud;
bring ex;

class PostBoii  {
    ck_postboii_emails: ex.Table;
    emailQueue: cloud.Queue;

    extern "./util/util.js" static inflight randomUUID(): str;
    extern "./util/util.js" static inflight createdDate(): str;
    // extern "./util/sendEmail.js" static inflight sendEmail(payload: str);
    extern "aws-sdk" static inflight sendEmail(params: Json): str;

    
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
        // This is the sendEMail functionality
        this.emailQueue.setConsumer(inflight (msg: str) => {
            try {
                log("SEND EMAIL MSG");
                log(msg);
                // PostBoii.sendEmail(msg);
            } catch err {
                log("Error during email queueing: ${err}");
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

    inflight queueEmail(messageJson: Json) {
        try {
            this.emailQueue.push(messageJson);
            log("Email queued: ${messageJson}");
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
  
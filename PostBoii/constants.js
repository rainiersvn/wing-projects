module.exports = {
    /**
     * App Specific Config
     */
    // MailMan
    CK_EMAILS_DB_NAME: "ck-mailman-emails",
    CK_SUBSCRIBE_EMAIL_LAMBDA_NAME: "MailMan-SubscribeEmail",
    CK_MAIL_MAN_API_NAME: "MailMan Backend API",
    CK_MAIL_MAN_BACKEND_BUCKET: "mailman-backend",
    CK_MAIL_MAN_SEND_EMAIL_QUEUE_NAME: "mailman-send-email",
    CK_QUEUE_EMAIL_LAMBDA_NAME: "MailMan-QueueEmail",
    CK_SEND_EMAIL_LAMBDA_NAME: "MailMan-SendEmail",

    /**
     * Dynamo DB Specific Config
     */
    DYNAMO_DB_PITR_ENABLED: false,
    DYNAMO_DB_DELETION_PROTECTION_ENABLED: true,
}

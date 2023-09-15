module.exports = {
    /**
     * App Specific Config
     */
    // PostBoii
    CK_EMAILS_DB_NAME: "ck-postboii-emails",
    CK_SUBSCRIBE_EMAIL_LAMBDA_NAME: "PostBoii-SubscribeEmail",
    CK_POSTBOII_API_NAME: "PostBoii Backend API",
    CK_POSTBOII_BACKEND_BUCKET: "postboii-backend",
    CK_POSTBOII_SEND_EMAIL_QUEUE_NAME: "postboii-send-email",
    CK_QUEUE_EMAIL_LAMBDA_NAME: "PostBoii-QueueEmail",
    CK_SEND_EMAIL_LAMBDA_NAME: "PostBoii-SendEmail",

    /**
     * Dynamo DB Specific Config
     */
    DYNAMO_DB_PITR_ENABLED: true,
    DYNAMO_DB_DELETION_PROTECTION_ENABLED: true,
}

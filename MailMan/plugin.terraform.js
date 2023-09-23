const { 
    CK_EMAILS_DB_NAME,
    CK_SUBSCRIBE_EMAIL_LAMBDA_NAME,
    CK_UNSUBSCRIBE_EMAIL_LAMBDA_NAME,
    CK_CONSUME_QUEUE_EMAIL_LAMBDA_NAME,
    CK_MAIL_MAN_API_NAME,
    CK_MAIL_MAN_BACKEND_BUCKET,
    CK_MAIL_MAN_SEND_EMAIL_QUEUE_NAME,
    CK_QUEUE_EMAIL_LAMBDA_NAME,
    CK_SEND_EMAIL_LAMBDA_NAME,
    DYNAMO_DB_PITR_ENABLED,
    DYNAMO_DB_DELETION_PROTECTION_ENABLED,
    CK_EMAILS_RECEIPT_DB_NAME,
} = require("./constants"); 

exports.postSynth = function(config) {
    config.terraform.backend = {
        s3: {
            bucket: "cloudkid-config",
            region: "us-east-1",
            key: "wing/target/fa.main.tfaws/.terraform/terraform.tfstate",
            dynamodb_table: "cloudkid-config-tfstate",
            encrypt: true
        }
    }

    /**
     * IMPORTANT!
     * All of the below config modifications are highly volatile, but seem to work across re-compiles.
     * They modify the TF resource names & sundries.
     */
    // DynamoDB Config
    const DYNAMO_DB_EMAIL_CONFIG = config.resource.aws_dynamodb_table["MailManHandler_MailMan-Emails_BE10A822"];
    const DYNAMO_DB_EMAIL_RECEIPT_CONFIG = config.resource.aws_dynamodb_table["MailManHandler_MailManEmail-Receipts_EA541854"];
    const DYNAMO_DB_CONFIG_ORIGINAL = config.resource.aws_dynamodb_table;
    config.resource.aws_dynamodb_table = {
        ...DYNAMO_DB_CONFIG_ORIGINAL,
        "MailManHandler_MailMan-Emails_BE10A822": {
            ...DYNAMO_DB_EMAIL_CONFIG,
            name: CK_EMAILS_DB_NAME,
            point_in_time_recovery: {
                enabled: DYNAMO_DB_PITR_ENABLED,
            },
            deletion_protection_enabled: DYNAMO_DB_DELETION_PROTECTION_ENABLED,
        },
        "MailManHandler_MailManEmail-Receipts_EA541854": {
            ...DYNAMO_DB_EMAIL_RECEIPT_CONFIG,
            name: CK_EMAILS_RECEIPT_DB_NAME,
            point_in_time_recovery: {
                enabled: DYNAMO_DB_PITR_ENABLED,
            },
            deletion_protection_enabled: DYNAMO_DB_DELETION_PROTECTION_ENABLED,
        }
    }
  
    // API Gateway Config
    const API_GATEWAY_CONFIG = config.resource.aws_api_gateway_rest_api["MailMan_api_74E309BA"];
    const API_GATEWAY_CONFIG_ORIGINAL = config.resource.aws_api_gateway_rest_api;
    config.resource.aws_api_gateway_rest_api = {
        ...API_GATEWAY_CONFIG_ORIGINAL,
        "MailMan_api_74E309BA": {
            ...API_GATEWAY_CONFIG,
            name: CK_MAIL_MAN_API_NAME,
            description: "The main API for the MailMan service"
        }
    }
    
    // S3 MailMan Bucket Config
    const S3_CONFIG = config.resource.aws_s3_bucket.Code;
    const S3_CONFIG_ORIGINAL = config.resource.aws_s3_bucket;
    delete S3_CONFIG.bucket_prefix; // We want a nice bucket name, wing auto sets a bucket_prefix and lets TF auto-gen the bucket name.
    config.resource.aws_s3_bucket = {
        ...S3_CONFIG_ORIGINAL,
        "Code": {
            ...S3_CONFIG,
            bucket: CK_MAIL_MAN_BACKEND_BUCKET,
            force_destroy: true,
        }
    }
    
    // MailMan SQS Config
    const SQS_CONFIG = config.resource.aws_sqs_queue["MailManHandler_MailMan-EmailQueue_E3433A22"];
    const SQS_CONFIG_ORIGINAL = config.resource.aws_sqs_queue;
    config.resource.aws_sqs_queue = {
        ...SQS_CONFIG_ORIGINAL,
        "MailManHandler_MailMan-EmailQueue_E3433A22": {
            ...SQS_CONFIG,
            name: CK_MAIL_MAN_SEND_EMAIL_QUEUE_NAME,
        }
    }
        
    // Lambda Config
    const SUBSCRIBE_EMAIL_LAMBDA_CONFIG = config.resource.aws_lambda_function["MailMan_MailMan-OnRequest-3fc9280c_7F6D4F0E"];
    const QUEUE_EMAIL_LAMBDA_CONFIG = config.resource.aws_lambda_function["MailMan_MailMan-OnRequest-52bc3c17_08EEFA23"];
    const UNSUBSCRIBE_EMAIL_LAMBDA_CONFIG = config.resource.aws_lambda_function["MailMan_MailMan-OnRequest-8d2e75ec_660861F4"];
    const SEND_EMAIL_LAMBDA_CONFIG = config.resource.aws_lambda_function["cloudFunction"];
    const CONSUME_QUEUE_EMAIL_LAMBDA_CONFIG = config.resource.aws_lambda_function["MailManHandler_MailMan-EmailQueue-SetConsumer-86898773_DBDA7311"];
    // const LAMBDA_CONFIG_ORIGINAL = config.resource.aws_lambda_function;
    config.resource.aws_lambda_function = {
        ...config.resource.aws_lambda_function,
        "MailMan_MailMan-OnRequest-3fc9280c_7F6D4F0E": { 
            ...SUBSCRIBE_EMAIL_LAMBDA_CONFIG,
            function_name: CK_SUBSCRIBE_EMAIL_LAMBDA_NAME,
            description: "Lambda function for subscribing emails through MailMan service"
        },
        "MailMan_MailMan-OnRequest-52bc3c17_08EEFA23": {
            ...QUEUE_EMAIL_LAMBDA_CONFIG,
            function_name: CK_QUEUE_EMAIL_LAMBDA_NAME,
            description: "Lambda function for queueing emails through MailMan service"
        },
        "MailMan_MailMan-OnRequest-8d2e75ec_660861F4": {
            ...UNSUBSCRIBE_EMAIL_LAMBDA_CONFIG,
            function_name: CK_UNSUBSCRIBE_EMAIL_LAMBDA_NAME,
            description: "Lambda function for unsubscribing emails through MailMan service"
        },
        "cloudFunction": {
            ...SEND_EMAIL_LAMBDA_CONFIG,
            function_name: CK_SEND_EMAIL_LAMBDA_NAME,
            description: "Lambda function for sending emails through MailMan service"
        },
        "MailManHandler_MailMan-EmailQueue-SetConsumer-86898773_DBDA7311": {
            ...CONSUME_QUEUE_EMAIL_LAMBDA_CONFIG,
            function_name: CK_CONSUME_QUEUE_EMAIL_LAMBDA_NAME,
            description: "Lambda function that MailMan service uses to consume queue messages"
        }
    }
    return config;
}
exports.name = "terraform-plugin";
const { 
    CK_EMAILS_DB_NAME,
    CK_SUBSCRIBE_EMAIL_LAMBDA_NAME,
    CK_MAIL_MAN_API_NAME,
    CK_MAIL_MAN_BACKEND_BUCKET,
    CK_MAIL_MAN_SEND_EMAIL_QUEUE_NAME,
    CK_QUEUE_EMAIL_LAMBDA_NAME,
    CK_SEND_EMAIL_LAMBDA_NAME,
    DYNAMO_DB_PITR_ENABLED,
    DYNAMO_DB_DELETION_PROTECTION_ENABLED,
} = require("./constants"); 

exports.postSynth = function(config) {
    config.terraform.backend = {
        s3: {
            bucket: "cloudkid-config",
            region: "us-east-1",
            key: "wing/target/main.tfaws/.terraform/terraform.tfstate",
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
    const DYNAMO_DB_CONFIG = config.resource.aws_dynamodb_table.MailManMailMan_exTable_D3E9871E;
    const DYNAMO_DB_CONFIG_ORIGINAL = config.resource.aws_dynamodb_table;
    config.resource.aws_dynamodb_table = {
        ...DYNAMO_DB_CONFIG_ORIGINAL,
        "MailManMailMan_exTable_D3E9871E": {
            ...DYNAMO_DB_CONFIG,
            name: CK_EMAILS_DB_NAME,
            point_in_time_recovery: {
                enabled: DYNAMO_DB_PITR_ENABLED,
            },
            deletion_protection_enabled: DYNAMO_DB_DELETION_PROTECTION_ENABLED,
        }
    }
  
    // API Gateway Config
    const API_GATEWAY_CONFIG = config.resource.aws_api_gateway_rest_api.cloudApi_api_2B334D75;
    const API_GATEWAY_CONFIG_ORIGINAL = config.resource.aws_api_gateway_rest_api;
    config.resource.aws_api_gateway_rest_api = {
        ...API_GATEWAY_CONFIG_ORIGINAL,
        "cloudApi_api_2B334D75": {
            ...API_GATEWAY_CONFIG,
            name: CK_MAIL_MAN_API_NAME,
            description: "The main API for the MailMan service"
        }
    }
    
    // S3 Postboii Bucket Config
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
    
    // Postboii SQS Config
    const SQS_CONFIG = config.resource.aws_sqs_queue.MailManMailMan_cloudQueue_4BDEDED6;
    const SQS_CONFIG_ORIGINAL = config.resource.aws_sqs_queue;
    config.resource.aws_sqs_queue = {
        ...SQS_CONFIG_ORIGINAL,
        "MailManMailMan_cloudQueue_4BDEDED6": {
            ...SQS_CONFIG,
            name: CK_MAIL_MAN_SEND_EMAIL_QUEUE_NAME,
        }
    }
        
    // // Lambda Config
    // const SUBSCRIBE_EMAIL_LAMBDA_CONFIG = config.resource.aws_lambda_function["cloudApi_cloudApi-OnRequest-cdafee6e_A6C8366F"];
    // const QUEUE_EMAIL_LAMBDA_CONFIG = config.resource.aws_lambda_function["cloudApi_cloudApi-OnRequest-86898773_701F5CA7"];
    // const SEND_EMAIL_LAMBDA_CONFIG = config.resource.aws_lambda_function["cloudApi_cloudApi-OnRequest-3fc9280c_5DA20E7A"];
    // // const LAMBDA_CONFIG_ORIGINAL = config.resource.aws_lambda_function;
    // config.resource.aws_lambda_function = {
    //     ...config.resource.aws_lambda_function,
    //     //
    //     "cloudApi_cloudApi-OnRequest-cdafee6e_A6C8366F": { 
    //         ...SUBSCRIBE_EMAIL_LAMBDA_CONFIG,
    //         function_name: CK_SUBSCRIBE_EMAIL_LAMBDA_NAME,
    //         description: "Lambda function for subscribing emails through MailMan service"
    //     },
    //     "cloudApi_cloudApi-OnRequest-86898773_701F5CA7": {
    //         ...QUEUE_EMAIL_LAMBDA_CONFIG,
    //         function_name: CK_QUEUE_EMAIL_LAMBDA_NAME,
    //         description: "Lambda function for queueing emails through MailMan service"
    //     },
    //     "cloudApi_cloudApi-OnRequest-3fc9280c_5DA20E7A": {
    //         ...SEND_EMAIL_LAMBDA_CONFIG,
    //         function_name: CK_SEND_EMAIL_LAMBDA_NAME,
    //         description: "Lambda function for sending emails through MailMan service"
    //     }
    // }
    return config;
}
exports.name = "terraform-plugin";
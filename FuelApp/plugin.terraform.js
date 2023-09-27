exports.postSynth = function(config) {
    config.terraform.backend = {
        s3: {
            bucket: "cloudkid-config",
            region: "us-east-1",
            key: "fuelapp/target/fa.main.tfaws/.terraform/terraform.tfstate",
            dynamodb_table: "cloudkid-config-tfstate",
            encrypt: true
        }
    }
    return config;
}
exports.name = "fa-terraform-plugin";
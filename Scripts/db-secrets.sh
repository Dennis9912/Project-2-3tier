# Script to create a Secret in AWS Secrets Manager
aws secretsmanager create-secret \
    --name "name of secret" \
    --secret-string '{"password":"define password"}' \
    --description "RDS MySQL password for Terraform"
aws secretsmanager get-secret-value --secret-id "name of secret"


#With a Username
aws secretsmanager create-secret \
    --name "name of secret" \
    --description "A secret for my instance" \
    --secret-string "{\"username\":\"define username\",\"password\":\"define password\"}"

#Verify the Secret
aws secretsmanager describe-secret --secret-id "name of secret"
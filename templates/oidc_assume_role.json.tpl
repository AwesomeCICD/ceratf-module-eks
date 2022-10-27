{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${AWS_ACCOUNT_ID}:oidc-provider/oidc.circleci.com/org/${CIRCLECI_ORG_ID}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "oidc.circleci.com/org/${CIRCLECI_ORG_ID}:aud": "${CIRCLECI_ORG_ID}"
                }
            }
        }
    ]
}
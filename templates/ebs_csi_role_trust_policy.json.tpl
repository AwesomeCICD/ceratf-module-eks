{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::${aws_account_id}:oidc-provider/oidc.eks.${aws_region}.amazonaws.com/id/${oidc_provider_identifier}"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "oidc.eks.${aws_region}.amazonaws.com/id/${oidc_provider_identifier}:aud": "sts.amazonaws.com",
          "oidc.eks.${aws_region}.amazonaws.com/id/${oidc_provider_identifier}:sub": "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }
  ]
}
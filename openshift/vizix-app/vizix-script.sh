export reg_username=mojixpull
export reg_password=AL2DR8en7PvLDZXFQipcLQQY
export authtoken=$(echo -n ${reg_username}:${reg_password} | base64 )
cat >./config.json <<EOL
{
    "auths": {
        "https://index.docker.io/v1/": {
            "auth": "${authtoken}"
        }
    }
}
EOL

oc delete secrets/external-registry
oc create secret generic external-registry \
  --from-file=.dockerconfigjson=./config.json \
  --type=kubernetes.io/dockerconfigjson
oc secrets link default external-registry --for=pull

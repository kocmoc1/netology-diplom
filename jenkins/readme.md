
# After install

## Get token
From control plane
```
 kubectl apply -f - <<EOF
 apiVersion: v1
 kind: Secret
 metadata:
   name: default-token
   annotations:
     kubernetes.io/service-account.name: default
 type: kubernetes.io/service-account-token
 EOF
 ```
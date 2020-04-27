[![CircleCI](https://circleci.com/gh/bndw/ddns.svg?style=svg)](https://circleci.com/gh/bndw/ddns)

# ddns

A quick Dynamic DNS hack for Route53. 

## Usage

Run the container with AWS credentials and it'll create an A record with the machine's public IP.

```sh
docker run --rm \
  -e ZONEID=FIXME \
  -e CNAME=home.example.com \
  -e AWS_ACCESS_KEY_ID=FIXME \
  -e AWS_SECRET_ACCESS_KEY=FIXME \
  -e AWS_REGION=FIXME \
  bndw/ddns:latest
```

#### Kubernetes CronJob

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: ddns
spec:
  schedule: "@daily"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: ddns
            image: bndw/ddns:latest
            env:
            - name: AWS_ACCESS_KEY_ID
              value: "FIXME"
            - name: AWS_SECRET_ACCESS_KEY
              value: "FIXME"
            - name: AWS_REGION
              value: "FIXME"
            - name: ZONEID 
              value: "FIXME"
            - name: CNAME 
              value: "home.example.com"
          restartPolicy: OnFailure
```

[![CircleCI](https://circleci.com/gh/bndw/dyndns.svg?style=svg&circle-token=5bfd0d4685ebd3d7a086284a546b1873bfc4b1e6)](https://circleci.com/gh/bndw/dyndns)

# dyndns

A quick Dynamic DNS hack for Route53. 

Run the container with AWS credentials and it'll create an A record with the machine's public IP.

## Usage

```
make build
```

#### Docker

```sh
docker run --rm \
  -e ZONEID=FIXME \
  -e CNAME=home.example.com \
  -e AWS_ACCESS_KEY_ID=FIXME \
  -e AWS_SECRET_ACCESS_KEY=FIXME \
  -e AWS_REGION=FIXME \
  bndw/dyndns:latest
```

#### Kubernetes CronJob

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: dyndns
spec:
  schedule: "@daily"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: dyndns
            image: bndw/dyndns:latest
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

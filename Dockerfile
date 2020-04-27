FROM amazon/aws-cli

RUN yum update -y && yum install -y bind-utils jq
COPY main.sh /
ENTRYPOINT ["/main.sh"]

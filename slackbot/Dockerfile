
############################
# STAGE 1 build Golang executable binary
############################

FROM golang:1.10 as builder
ARG STORAGE_ACCT_URL
ARG STORAGE_ACCT_KEY

ENV bin_dir=/go/bin/
RUN apt-get update && apt-get -y install openssl libcurl4-openssl-dev libunwind8 icu-devtools
RUN apt-get update && apt-get -y install rsync libunwind8
RUN mkdir /tmp/azcopy && \
     wget -O /tmp/azcopy/azcopy.tar.gz https://aka.ms/downloadazcopylinux64 &&  \
     tar -xf /tmp/azcopy/azcopy.tar.gz -C /tmp/azcopy &&  \
     /tmp/azcopy/install.sh

WORKDIR $GOPATH/src/github.com/buildit/slackbot
ADD . $GOPATH/src/github.com/buildit/slackbot/
RUN go get -u github.com/jstemmer/go-junit-report
RUN go get -d ./...
RUN go build -o ${bin_dir}/bot-server.sh ./cmd/bot-server/main.go
RUN go test ./... | go-junit-report > TestReport.xml

 RUN azcopy --quiet \
     --source ./TestReport.xml \
     --destination "${STORAGE_ACCT_URL}" \
     --dest-key "${STORAGE_ACCT_KEY}"

############################
# STAGE 2 Build small image with only binary
############################

# FROM golang:1.10-alpine
# ENV bin_dir=/go/bin/
# COPY --from=builder ${bin_dir}/bot-server.sh /go/bin/bot-server.sh
# RUN cd ${bin_dir} && ls
# ENTRYPOINT ["/go/bin/bot-server.sh"]
FROM golang:1.12.1-alpine AS golang

############################
# STAGE 1 build Golang executable binary
############################

FROM golang AS builder
ENV bin_dir=/go/bin/
RUN apk update && apk add --no-cache openssl openssh curl bash git openssh libcurl
WORKDIR $GOPATH/src/github.com/buildit/slackbot
ADD . $GOPATH/src/github.com/buildit/slackbot/
RUN go get -d -v ./...
RUN go build -v -o ${bin_dir}/bot-server.sh ./cmd/bot-server/main.go
RUN go get -u github.com/jstemmer/go-junit-report
RUN mkdir /go/TestResults
RUN go test -v ./... | go-junit-report > /go/TestResults/TestReport.xml


############################
# STAGE 2 Upload test results to Azure
############################

FROM microsoft/dotnet:latest AS tester

ARG STORAGE_ACCT_URL
ARG STORAGE_ACCT_KEY
ARG BUILD_NUMBER

RUN apt-get update && apt-get -y install rsync --no-install-recommends apt-utils
RUN mkdir /tmp/azcopy && \
    wget -O /tmp/azcopy/azcopy.tar.gz https://aka.ms/downloadazcopyprlinux &&  \
    tar -xf /tmp/azcopy/azcopy.tar.gz -C /tmp/azcopy &&  \
    /tmp/azcopy/install.sh

RUN rm -rf /tmp/azcopy

COPY --from=builder /go/TestResults/TestReport.xml ./TestReport.xml

RUN azcopy \
     --source ./TestReport.xml \
     --destination "${STORAGE_ACCT_URL}/TestReport_${BUILD_NUMBER}.xml" \
     --dest-key "${STORAGE_ACCT_KEY}"


############################
# STAGE 3 Build small image with only binary
############################

FROM golang AS final
ENV bin_dir=/go/bin/
COPY --from=builder ${bin_dir}/bot-server.sh /go/bin/bot-server.sh
RUN cd ${bin_dir} && ls
ENTRYPOINT ["/go/bin/bot-server.sh"]
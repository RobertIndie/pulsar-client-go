# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

# Explicit version of Pulsar and Golang images should be
# set via the Makefile or CLI
ARG PULSAR_IMAGE=czcoder/pulsar:3.3.0-0771f81
FROM $PULSAR_IMAGE
USER root
ARG GO_VERSION=1.18
ARG ARCH=amd64

RUN curl -L https://dl.google.com/go/go${GO_VERSION}.linux-${ARCH}.tar.gz -o golang.tar.gz && \
    mkdir -p /pulsar/go && tar -C /pulsar -xzf golang.tar.gz

ENV PATH /pulsar/go/bin:$PATH

RUN apt-get update && apt-get install -y git && apt-get install -y gcc


### Add pulsar config
COPY integration-tests/certs /pulsar/certs
COPY integration-tests/tokens /pulsar/tokens
COPY integration-tests/conf/.htpasswd \
     integration-tests/conf/client.conf \
     integration-tests/conf/standalone.conf \
     /pulsar/conf/

COPY . /pulsar/pulsar-client-go

ENV PULSAR_EXTRA_OPTS="-Dpulsar.auth.basic.conf=/pulsar/conf/.htpasswd"

WORKDIR /pulsar/pulsar-client-go

ENV GOPATH=/pulsar/go
ENV GOCACHE=/tmp/go-cache

# Install dependencies
RUN go mod download

# Basic compilation
RUN go build ./pulsar
RUN go build ./pulsaradmin
RUN go build -o bin/pulsar-perf ./perf

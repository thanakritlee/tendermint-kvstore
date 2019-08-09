FROM ubuntu:16.04 

RUN apt-get update && \
    apt-get -qq -y install curl apt-utils build-essential git-core
RUN rm /bin/sh && ln -s /bin/bash /bin/sh

# Install Tendermint.
RUN curl -L https://git.io/fFfOR | bash && \
    source ~/.profile

# Init Tendermit.
# Will create the required files for single,
# local node.
RUN tendermint init


# Copy Go application.
COPY . .

# Download Go dependencies.
RUN cd fabric-api/ && \
    go mod download

# Build Go application binary.
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o kvstore

CMD ./kvstore -config "$HOME/.tendermint/config/config.toml"

EXPOSE 26657
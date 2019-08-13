# GoLang build stage.
FROM golang:1.12 as builder

WORKDIR /app

COPY . .

RUN go mod download

# Build Go application binary.
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o kvstore

# Final stage.
FROM ubuntu:16.04 

RUN apt-get update && \
    apt-get -qq -y install \
    curl apt-utils \
    build-essential \
    git-core \
    unzip

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN curl -LO https://github.com/tendermint/tendermint/releases/download/v0.31.8/tendermint_v0.31.8_linux_amd64.zip && \
    unzip tendermint_v0.31.8_linux_amd64.zip

# Init Tendermit.
# Will create the required files for single,
# local node.
RUN ./tendermint init


# Copy Go binary.
COPY --from=builder /app/kvstore ./

CMD ./kvstore -config "$HOME/.tendermint/config/config.toml"

EXPOSE 26657
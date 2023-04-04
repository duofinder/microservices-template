FROM golang:1.19-alpine as builder

WORKDIR /app

COPY go.mod ./

COPY go.sum ./

RUN go mod download

COPY main.go ./

COPY ./handlers ./handlers
COPY ./repositories ./repositories
COPY ./services ./services
COPY ./types ./types
COPY ./utils ./utils

EXPOSE 5432

RUN go mod tidy

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /microservice

CMD [ "/microservice" ]
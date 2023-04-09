package main

import (
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/your_account/your_project/handlers"
)

func main() {
	lambda.Start(handlers.Lambda)
}

package handlers

import (
	"context"

	"github.com/aws/aws-lambda-go/events"
	// _ "github.com/lib/pq"
)

func Lambda(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// ADD HEADERS HERE
	// headers := map[string]string{
	// 	"Access-Control-Allow-Origin":  "",
	// 	"Access-Control-Allow-Methods": "",
	// 	"Content-Type":                 "",
	// }

	// ADD CONNECTION TO THE DATABASE ONLY IF ITS NEEDED
	// db, err := sql.Open("postgres", os.Getenv("DATABASE_POSTGRES_CONNSTR"))
	// if err != nil {
	// 	return events.APIGatewayProxyResponse{
	// 		Body:       "Internal Server Error",
	// 		Headers:    headers,
	// 		StatusCode: http.StatusInternalServerError,
	// 	}, nil
	// }
	// defer db.Close()

	// ADD VALIDATION TO THE REQUEST.BODY IF ITS NEEDED
	// data, err := validation.Validate(request.Body, &types.Type)
	// if err != nil {
	// 	return events.APIGatewayProxyResponse{
	// 		Body:       "Bad Request. Body provided is incorrect!",
	// 		Headers:    headers,
	// 		StatusCode: http.StatusBadRequest,
	// 	}, nil
	// }

	// CALL SERVICE HERE
	// resp := services.Service(&types.LambdaImput{})

	return events.APIGatewayProxyResponse{}, nil
}

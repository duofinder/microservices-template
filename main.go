package main

import (
	"context"
	"database/sql"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"

	_ "github.com/lib/pq"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	router := gin.New()

	logger := log.Default()

	router.Use(gin.Logger())
	router.Use(gin.Recovery())

	_, err := sql.Open("postgres", os.Getenv("DATABASE_POSTGRES_CONNSTR"))
	if err != nil {
		log.Fatalf("error trying to connect to database. err: %v", err)
	}

	srv := &http.Server{
		Addr:         os.Getenv("SERVER_ADDR"),
		ReadTimeout:  time.Second * 2,
		WriteTimeout: time.Second * 6,
		Handler:      router,
		ErrorLog:     logger,
	}

	if err != nil {
		log.Fatal("error trying to create new server")
	}

	go func() {
		if err := srv.ListenAndServe(); err != nil {
			log.Fatalf("error trying to listen: %s\n", err)
		}
	}()

	<-ctx.Done()

	stop()
	log.Println("shutting down gracefully, press Ctrl+C again to force")

	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(ctx); err != nil {
		log.Printf("server forced to shutdown: %v\n", err)
	}
}

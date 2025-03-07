package main

import (
	"fmt"
	"github.com/labstack/echo/v4"
	"log"
)

func handler(c echo.Context) error {
	fmt.Print("Hello, World!")
	return c.String(200, "Hello, World!")
}

func main() {
	echoServer := echo.New()
	echoServer.GET("/", handler)
	log.Fatal(echoServer.Start(":8080"))
}

package main

import (
	"encoding/json"
	"fmt"
	"github.com/labstack/echo/v4"
	"log"
	"net/http"
)

func handler(c echo.Context) error {
	fmt.Print("Hello, World!")
	return c.String(200, "Hello, World!")
}

func weatherHandler(c echo.Context) error {
	// send request to https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&hourly=temperature_2m&models=icon_seamless
	// parse the response and return the temperature
	req, err := http.NewRequest("GET", "https://api.open-meteo.com/v1/forecast?latitude=52.52&longitude=13.41&hourly=temperature_2m&models=icon_seamless", nil)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Failed to create request")
	}
	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Failed to send request")
	}
	if resp.StatusCode != http.StatusOK {
		return echo.NewHTTPError(http.StatusInternalServerError, "Failed to get weather data")
	}
	res := make(map[string]any)
	err = json.NewDecoder(resp.Body).Decode(&res)
	if err != nil {
		return echo.NewHTTPError(http.StatusInternalServerError, "Failed to decode response")
	}

	return c.JSON(http.StatusOK, res)
}

func main() {
	echoServer := echo.New()
	echoServer.GET("/", handler)
	echoServer.GET("/weather", weatherHandler)
	log.Fatal(echoServer.Start(":8080"))
}

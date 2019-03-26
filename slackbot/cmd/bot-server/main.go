package main

import (
	"github.com/Microsoft/ApplicationInsights-Go/appinsights"
	"github.com/buildit/slackbot/pkg/config"
	"github.com/buildit/slackbot/pkg/database"
	"github.com/buildit/slackbot/pkg/ai"
	"github.com/buildit/slackbot/pkg/service"
	"github.com/gorilla/mux"
	log "github.com/sirupsen/logrus"
	"net/http"
)

// main function to boot up everything
func main() {
	appInsightsClient := appinsights.NewTelemetryClient(config.AppInsights.InstrumentationKey)
	defer appInsightsClient.Channel().Close()
	log.AddHook(&ai.AppInsightsHook{
		Client: appInsightsClient,
	})

	var err error
	database.DBCon, err = database.OpenWrite()
	if err != nil {
		log.Fatal(err)
	}
	defer database.CloseDB()

	router := mux.NewRouter()
	router.HandleFunc("/", service.ListenAndServeHome)
	router.HandleFunc("/error", service.ListenAndServeError)
	router.HandleFunc("/events", service.ListenAndServeEvents).Methods("POST")
	router.HandleFunc("/slash", service.ListenAndServeSlash).Methods("POST")
	router.HandleFunc("/interactions", service.ListenAndServeInteractions).Methods("POST")
	log.Println("Server listening")
	log.Fatal(http.ListenAndServe(":80", router))
}

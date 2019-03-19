package main

import (
	"github.com/buildit/slackbot/pkg/database"
	"github.com/buildit/slackbot/pkg/service"
	"github.com/gorilla/mux"
	log "github.com/sirupsen/logrus"
	"net/http"
)

// main function to boot up everything
func main() {

	var err error
	database.DBCon, err = database.OpenWrite()
	if err != nil {
		log.Fatal(err)
	}
	defer database.CloseDB()

	router := mux.NewRouter()
	router.HandleFunc("/", service.ListenAndServeHome)
	router.HandleFunc("/events", service.ListenAndServeEvents).Methods("POST")
	router.HandleFunc("/slash", service.ListenAndServeSlash).Methods("POST")
	router.HandleFunc("/interactions", service.ListenAndServeInteractions).Methods("POST")
	log.Println("Server listening")
	log.Fatal(http.ListenAndServe(":80", router))

}

package main

import (
	"fmt"
	"github.com/buildit/slackbot/pkg/database"
	"github.com/buildit/slackbot/pkg/service"
	"github.com/gorilla/mux"
	"log"
	"net/http"
)

// main function to boot up everything
func main() {

	var err error
	database.DBCon, err = database.OpenWrite()
	if err != nil {
		log.Fatal(err)
	}

	router := mux.NewRouter()
	router.HandleFunc("/", service.ListenAndServeHome)
	router.HandleFunc("/events", service.ListenAndServeEvents).Methods("POST")
	router.HandleFunc("/slash", service.ListenAndServeSlash).Methods("POST")
	router.HandleFunc("/interactions", service.ListenAndServeInteractions).Methods("POST")
	fmt.Println("[INFO] Server listening")
	log.Fatal(http.ListenAndServe(":80", router))
	defer database.CloseDB()

}

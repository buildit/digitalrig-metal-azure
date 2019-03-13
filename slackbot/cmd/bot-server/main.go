package main

import (
	"fmt"
	"github.com/buildit/slackbot/pkg/bot-server"
	"github.com/buildit/slackbot/pkg/database"
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
	router.HandleFunc("/", bot_server.ListenAndServeHome)
	router.HandleFunc("/events", bot_server.ListenAndServeEvents).Methods("POST")
	router.HandleFunc("/slash", bot_server.ListenAndServeSlash).Methods("POST")
	router.HandleFunc("/interactions", bot_server.ListenAndServeInteractions).Methods("POST")
	fmt.Println("[INFO] Server listening")
	log.Fatal(http.ListenAndServe(":4390", router))
	defer database.CloseDB()

}

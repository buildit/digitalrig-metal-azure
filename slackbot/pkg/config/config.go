package config

import (
	"github.com/kelseyhightower/envconfig"
	log "github.com/sirupsen/logrus"
)

// Config contains environment variables used to configure the app
type Config struct {
	VerificationToken string
	OauthToken        string
	PollBucket        string `default:"POLL"`
}

type AppInsightsConfig struct {
	InstrumentationKey string
}

var Env Config
var AppInsights AppInsightsConfig

func init() {
	err := envconfig.Process("slackbot", &Env)
	if err != nil {
		log.Fatal(err.Error())
	}
}

func init() {
	err := envconfig.Process("appinsights", &AppInsights)
	if err != nil {
		log.Fatal(err.Error())
	}
}

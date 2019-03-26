package ai

import (
	"encoding/json"
	"fmt"
	"github.com/Microsoft/ApplicationInsights-Go/appinsights"
	"github.com/Microsoft/ApplicationInsights-Go/appinsights/contracts"
	log "github.com/sirupsen/logrus"
)
type AppInsightsHook struct {
	Client appinsights.TelemetryClient
}

func (hook *AppInsightsHook) Levels() []log.Level {
	return log.AllLevels
}

func (hook *AppInsightsHook) Fire(entry *log.Entry) error {
	if _, ok := entry.Data["message"]; !ok {
		entry.Data["message"] = entry.Message
	}

	level := convertSeverityLevel(entry.Level)
	telemetry := appinsights.NewTraceTelemetry(entry.Message, level)

	for key, value := range entry.Data {
		value = formatData(value)
		telemetry.Properties[key] = fmt.Sprintf("%v", value)
	}

	hook.Client.Track(telemetry)
	return nil
}

func convertSeverityLevel(level log.Level) contracts.SeverityLevel {
	switch level {
	case log.PanicLevel:
		return contracts.Critical
	case log.FatalLevel:
		return contracts.Critical
	case log.ErrorLevel:
		return contracts.Error
	case log.WarnLevel:
		return contracts.Warning
	case log.InfoLevel:
		return contracts.Information
	case log.DebugLevel, log.TraceLevel:
		return contracts.Verbose
	default:
		return contracts.Information
	}
}

func formatData(value interface{}) (formatted interface{}) {
	switch value := value.(type) {
	case json.Marshaler:
		return value
	case error:
		return value.Error()
	case fmt.Stringer:
		return value.String()
	default:
		return value
	}
}


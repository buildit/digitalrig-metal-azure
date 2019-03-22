package service

import (
	"bytes"
	"encoding/json"
	"github.com/buildit/slackbot/pkg/config"
	"github.com/buildit/slackbot/pkg/database"
	"github.com/buildit/slackbot/pkg/poll"
	"github.com/nlopes/slack"
	"github.com/nlopes/slack/slackevents"
	log "github.com/sirupsen/logrus"
	"io/ioutil"
	"math/rand"
	"net/http"
	"net/url"
	"strings"
	"time"
)

var api = slack.New(config.Env.OauthToken)
var slackPoll = poll.Poll{}

func init() {
	rand.Seed(time.Now().UnixNano())
}

func ListenAndServeHome(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello from the slackbot"))
	return
}

func ListenAndServeSlash(w http.ResponseWriter, r *http.Request) {
	s, err := slack.SlashCommandParse(r)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	if !s.ValidateToken(config.Env.VerificationToken) {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	switch s.Command {
	case "/poll":

		//Take the submitted parameters, normalize the text, and create a Slice of strings
		params := &slack.Msg{Text: s.Text}
		normalizedParams := strings.Map(poll.Normalize, params.Text)
		slicedParams := poll.SplitParameters(normalizedParams)
		log.Printf("Poll Submission detected with Message Paramters:%q", slicedParams)

		if len(slicedParams) < 1 {
			log.Error("No Topic Provided for the submitted poll")
			w.WriteHeader(http.StatusInternalServerError)
		}
		if len(slicedParams) > 10 {
			log.Error("Polling only supports up to 10 options")
			w.WriteHeader(http.StatusInternalServerError)
		}
		slackPoll = poll.CreatePoll(slicedParams)

		poll.AddPoll(database.DBCon, slackPoll.Identifier, slackPoll)

		channelID, timestamp, err := api.PostMessage(s.ChannelID, slack.MsgOptionText(slackPoll.Title, false), slack.MsgOptionAttachments(slackPoll.Attachment))

		if err != nil {
			log.Printf("%s", err)
			return
		}
		log.Printf("Poll '%s' successfully created on channel %s at %s", slackPoll.Identifier, channelID, timestamp)
	}

}
func ListenAndServeInteractions(w http.ResponseWriter, r *http.Request) {
	buf, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Errorf("Failed to read request body: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
	}

	jsonStr, err := url.QueryUnescape(string(buf)[8:])
	if err != nil {
		log.Errorf("Failed to unescape request body: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
	}
	var message slack.InteractionCallback
	if err := json.Unmarshal([]byte(jsonStr), &message); err != nil {
		log.Errorf("Failed to decode json message from slack: %s", jsonStr)
		w.WriteHeader(http.StatusInternalServerError)
	}
	// Only accept message from slack with valid token
	if message.Token != config.Env.VerificationToken {
		log.Errorf("Invalid token: %s", message.Token)
		w.WriteHeader(http.StatusUnauthorized)
		return
	}

	log.Printf("Received Message: %s", jsonStr)

	callbackType := ""
	id := message.CallbackID
	if strings.Contains(id, "poll") {
		callbackType = "poll"
	}
	log.Printf("CallbackType: %s", callbackType)

	switch callbackType {
	case "poll":

		slackPoll, err = poll.GetPoll(database.DBCon, id)

		action := message.Actions[0]
		if action.Name == "actionCancel" {
			log.Println("Cancel Poll was selected")
			slackPoll = poll.CancelPoll(message.User.Name, slackPoll)

			channelID, timestamp, text, err := api.UpdateMessage(message.Channel.ID, message.MessageTs, slack.MsgOptionText(slackPoll.Title, false), slack.MsgOptionAttachments(slackPoll.Attachment))
			if err != nil {
				log.Printf("%s", err)
				return
			}

			poll.DeletePoll(database.DBCon, id)

			log.Printf("Poll '%s' deleted on channel %s at %s. Reponse with text %s", slackPoll.Identifier, channelID, timestamp, text)
		} else { //It's a vote calllback
			slackPoll = poll.AddVote(slackPoll, message.User.Name, message.Actions[0].Value)
		}

		//Update Attachment text to ensure it reflects current votes
		slackPoll.Attachment.Text = poll.GetOptionsString(slackPoll)

		//Persist the Updated Poll
		poll.AddPoll(database.DBCon, id, slackPoll)

		//Update the poll in Slack
		channelID, timestamp, text, err := api.UpdateMessage(message.Channel.ID, message.MessageTs, slack.MsgOptionText(slackPoll.Attachment.Title, false), slack.MsgOptionAttachments(slackPoll.Attachment))
		if err != nil {
			log.Printf("%s", err)
			return
		}
		log.Printf("Poll '%s' successfully sent to channel %s at %s. Reponse with text %s", slackPoll.Identifier, channelID, timestamp, text)
	}

}

func ListenAndServeEvents(w http.ResponseWriter, r *http.Request) {

	buf := new(bytes.Buffer)
	buf.ReadFrom(r.Body)
	body := buf.String()
	eventsAPIEvent, e := slackevents.ParseEvent(json.RawMessage(body), slackevents.OptionVerifyToken(&slackevents.TokenComparator{VerificationToken: config.Env.VerificationToken}))
	if e != nil {
		w.WriteHeader(http.StatusInternalServerError)
	}

	if eventsAPIEvent.Type == slackevents.URLVerification {
		var r *slackevents.ChallengeResponse
		err := json.Unmarshal([]byte(body), &r)
		if err != nil {
			w.WriteHeader(http.StatusInternalServerError)
		}
		w.Header().Set("Content-Type", "text")
		w.Write([]byte(r.Challenge))
	}
	if eventsAPIEvent.Type == slackevents.CallbackEvent {
		innerEvent := eventsAPIEvent.InnerEvent
		switch ev := innerEvent.Data.(type) {
		case *slackevents.AppMentionEvent:
			//TODO: Add initial  event support to allow someone to ask Miles for Help on supported comamnds
			channelID, timeStamp, _ := api.PostMessage(ev.Channel, slack.MsgOptionText("Hello", false))
			log.Printf("Message successfully sent to channel %s at %s", channelID, timeStamp)
		}
	}

}

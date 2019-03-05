package poll

import (
	"fmt"
	"github.com/buildit/slackbot/pkg/util"
	"github.com/nlopes/slack"
	"log"
	"math/rand"
	"sort"
	"strconv"
)

type Poll struct {
	Title       string
	PollOptions map[int]*Option
	Attachment  slack.Attachment
	Buttons     []slack.AttachmentAction
	Identifier  string
}

type Option struct {
	Name   string
	Vote   int
	Voters []string
}

func GetOptionsString(myPoll Poll) string {
	//TODO: Need to determine a way to post the options and votes without using emojis/reactions as below.  This requires anyone using the app to ensure their app has the emojis installed.
	keys := make([]int, 0)
	for k, _ := range myPoll.PollOptions {
		keys = append(keys, k)
	}

	sort.Ints(keys)

	formattedOptions := ""
	for _, k := range keys {
		if myPoll.PollOptions[k].Vote < 1 {
			formattedOptions = formattedOptions + fmt.Sprintf(":%s: %s\n\n", util.ConvertNumToString(k), myPoll.PollOptions[k].Name)
		} else {
			formattedOptions = formattedOptions + fmt.Sprintf(":%s: %s :vote%d:\n\n", util.ConvertNumToString(k), myPoll.PollOptions[k].Name, myPoll.PollOptions[k].Vote)
		}

	}

	return formattedOptions
}

func AddVote(poll Poll, name string, optionNumber string) Poll {
	num, err := strconv.Atoi(optionNumber)

	if err != nil {
		log.Printf("Unable to add vote due to error: %s", err)
		return poll
	}

	//Remove votes from any option  that the user already voted against before adding/changing a vote to prevent voting more than once
	for _, option := range poll.PollOptions {
		if util.Contains(option.Voters, name) {
			option.Voters = util.Remove(option.Voters, name)
			option.Vote = len(option.Voters)
		}
	}

	poll.PollOptions[num].Voters = append(poll.PollOptions[num].Voters, name)
	poll.PollOptions[num].Vote = len(poll.PollOptions[num].Voters)
	return poll
}

//Normalize the text being used to create a poll. (ex.  Slack will respond text using Smart quotes, etc).
func Normalize(in rune) rune {
	switch in {
	case '“', '‹', '”', '›':
		return '"'
	case '‘', '’':
		return '\''
	}
	return in
}

//Creates a slice of strings. Anything within double quotes is treated as a single string
func SplitParameters(inputString string) []string {
	var out []string
	pos := 0
	quoted := false
	for i, c := range inputString {
		switch c {
		case '"':
			quoted = !quoted
		case ' ':
			if !quoted {
				out = append(out, inputString[pos:i])
				pos = i + 1
			}
		}
	}

	if pos < len(inputString) {
		if quoted {
			log.Println("missing closing quote")
		}
		out = append(out, inputString[pos:])
	}
	return removeWrappedQuotes(out)
}

func removeWrappedQuotes(inputString []string) []string {
	var newout []string
	for _, value := range inputString {
		if len(value) > 0 && value[0] == '"' {
			value = value[1:]

		}
		if len(value) > 0 && value[len(value)-1] == '"' {
			value = value[:len(value)-1]
		}
		newout = append(newout, value)
	}
	return newout
}

func CancelPoll(user string, mypoll Poll) Poll {
	mypoll.Buttons = []slack.AttachmentAction{}
	mypoll.Attachment = slack.Attachment{
		Title: fmt.Sprintf(":x: %s cancelled the request to conduct a poll", user),
	}
	mypoll.PollOptions = map[int]*Option{}
	mypoll.Title = ""

	return mypoll
}

func CreatePoll(slicedParams []string) Poll {
	pollIdentifier := "poll-" + strconv.Itoa(rand.Intn(100000))
	newPoll := Poll{
		Title:       slicedParams[0],
		Buttons:     []slack.AttachmentAction{},
		PollOptions: map[int]*Option{},
		Identifier:  pollIdentifier,
	}
	for i, value := range slicedParams {
		if i > 0 { //processing options
			option := slack.AttachmentAction{
				Name:  value,
				Text:  fmt.Sprintf(":%s:", util.ConvertNumToString(i)),
				Type:  "button",
				Style: "default",
				Value: strconv.Itoa(i),
			}
			//Add options to struct initialized with zero votes
			newPoll.PollOptions[i] = &Option{
				Name:   value,
				Vote:   0,
				Voters: []string{},
			}
			newPoll.Buttons = append(newPoll.Buttons, option)
		}
	}
	option := slack.AttachmentAction{
		Name:  "actionCancel",
		Text:  "Delete Poll",
		Type:  "button",
		Style: "danger",
		Value: "cancel",
	}
	newPoll.Buttons = append(newPoll.Buttons, option)

	var attachment = slack.Attachment{
		Text:       GetOptionsString(newPoll),
		Color:      "#f9a41b",
		CallbackID: pollIdentifier,
		Actions:    newPoll.Buttons,
	}
	newPoll.Attachment = attachment

	return newPoll
}

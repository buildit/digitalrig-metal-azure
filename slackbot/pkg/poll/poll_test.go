// +build unit_tests

package poll

import (
	"github.com/buildit/slackbot/pkg/util"
	"github.com/nlopes/slack"
	"testing"
)

func TestSplitParameters(t *testing.T) {
	input := `"My Topic's" Option1 Option2 "Option 3"`

	output := SplitParameters(input)

	if output[0] != "My Topic's" {
		t.Errorf("First item in slice is incorrect, got: %s, want: %s.", output[0], "My Topic's")
	}
	if output[1] != "Option1" {
		t.Errorf("Second item in slice is incorrect, got: %s, want: %s.", output[1], "Option1")
	}
	if output[2] != "Option2" {
		t.Errorf("Thrid item in slice is incorrect, got: %s, want: %s.", output[2], "Option2")
	}
	if output[3] != "Option 3" {
		t.Errorf("Third item in slice is incorrect, got: %s, want: %s.", output[3], "Option 3")
	}
}

func TestOptionTextBuider(t *testing.T) {
	option1 := Option{
		Name: "Option1",
		Vote: 1,
	}
	option2 := Option{
		Name: "Option2",
		Vote: 2,
	}
	option3 := Option{
		Name: "Option3",
		Vote: 1,
	}

	m := make(map[int]*Option)
	m[1] = &option1
	m[2] = &option2
	m[3] = &option3

	inputPoll := Poll{
		Title:       "My Poll",
		PollOptions: m,
		Attachment:  slack.Attachment{},
		Buttons:     []slack.AttachmentAction{},
	}

	output := GetOptionsString(inputPoll)
	expectedOutput := ":one: Option1 :vote1:\n\n:two: Option2 :vote2:\n\n:three: Option3 :vote1:\n\n"
	if output != expectedOutput {
		t.Errorf("Options did not process appropriately, got:\n%s\nwant:\n%s", output, expectedOutput)

	}
}
func TestOptionTextBuiderContainingZeroVotes(t *testing.T) {
	option1 := Option{
		Name: "Option1",
		Vote: 1,
	}
	option2 := Option{
		Name: "Option2",
		Vote: 0,
	}
	option3 := Option{
		Name: "Option3",
		Vote: 1,
	}

	m := make(map[int]*Option)
	m[1] = &option1
	m[2] = &option2
	m[3] = &option3

	inputPoll := Poll{
		Title:       "My Poll",
		PollOptions: m,
		Attachment:  slack.Attachment{},
		Buttons:     []slack.AttachmentAction{},
	}

	output := GetOptionsString(inputPoll)
	expectedOutput := ":one: Option1 :vote1:\n\n:two: Option2\n\n:three: Option3 :vote1:\n\n"
	if output != expectedOutput {
		t.Errorf("Options did not process appropriately, got:\n%s\nwant:\n%s", output, expectedOutput)

	}
}

func TestMultipleVoteProtection(t *testing.T) {
	voters := []string{"tester1"}
	option1 := Option{
		Name:   "Option1",
		Vote:   1,
		Voters: voters,
	}
	option2 := Option{
		Name: "Option2",
		Vote: 0,
	}
	option3 := Option{
		Name: "Option3",
		Vote: 1,
	}

	m := make(map[int]*Option)
	m[1] = &option1
	m[2] = &option2
	m[3] = &option3

	inputPoll := Poll{
		Title:       "My Poll",
		PollOptions: m,
		Attachment:  slack.Attachment{},
		Buttons:     []slack.AttachmentAction{},
	}

	poll := AddVote(inputPoll, "tester1", "2")

	if util.Contains(poll.PollOptions[1].Voters, "tester1") {
		t.Errorf("Option contained name after voting on another option. %s contained Voters %s", poll.PollOptions[1].Name, poll.PollOptions[1].Voters)
	}
}

func TestPollCreation(t *testing.T) {
	input := `"My Poll Title" Option1 Option2 "Option 3"`

	params := SplitParameters(input)

	poll := CreatePoll(params)

	if poll.Title != "My Poll Title" {
		t.Errorf("Poll not instantiated corretly. Poll Title=%s And should Be %s", poll.Title, "My Poll Title")
	}
	if poll.PollOptions[1].Name != "Option1" {
		t.Errorf("Poll not instantiated corretly. Poll Option1=%s And should Be %s", poll.PollOptions[1].Name, "Option1")
	}
	if poll.PollOptions[2].Name != "Option2" {
		t.Errorf("Poll not instantiated corretly. Poll Option2=%s And should Be %s", poll.PollOptions[2].Name, "Option2")
	}
	if poll.PollOptions[3].Name != "Option 3" {
		t.Errorf("Poll not instantiated corretly. Poll Option3=%s And should Be %s", poll.PollOptions[3].Name, "Option 3")
	}

}

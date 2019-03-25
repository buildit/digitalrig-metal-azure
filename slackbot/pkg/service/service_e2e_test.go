package service

import "net/http"
import "io/ioutil"
import "testing"

func TestE2ESlackbotHelloWorldMessage(t *testing.T) {
	// Call the slackbot end point.
	httpResponse, err := http.Get("https://builditsandboxdemoappdev.azurewebsites.net/")
	if err != nil {
		panic(err)
	}

	// Parse the response body.
	defer httpResponse.Body.Close()
	body, err := ioutil.ReadAll(httpResponse.Body)
	actual := string(body)

	// Assert the result.
	expected := "Hello from the slackbot"
	if actual != expected {
		t.Errorf("Assertion Failed! Expected: %s. Actual: %s", expected, actual)
	}
}

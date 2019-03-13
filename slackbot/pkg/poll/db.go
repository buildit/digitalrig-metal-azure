package poll

import (
	"encoding/json"
	"fmt"
	"github.com/buildit/slackbot/pkg/config"
	"go.etcd.io/bbolt"
	"log"
)

var pollBucket = []byte(config.Env.PollBucket)

func AddPoll(db *bbolt.DB, id string, poll Poll) error {
	slackPollBytes, err := json.Marshal(poll)
	if err != nil {
		return fmt.Errorf("could not marshal poll json: %v", err)
	}

	err = db.Update(func(tx *bbolt.Tx) error {
		err = tx.Bucket([]byte("DB")).Bucket(pollBucket).Put([]byte(id), slackPollBytes)
		if err != nil {
			return fmt.Errorf("could not set config: %v", err)
		}
		return nil
	})
	log.Printf("Successfully persisted Poll ID=%s to Bolt\n", id)
	return err
}
func DeletePoll(db *bbolt.DB, id string) error {
	var err error

	err = db.Update(func(tx *bbolt.Tx) error {
		err = tx.Bucket([]byte("DB")).Bucket(pollBucket).Delete([]byte(id))
		if err != nil {
			return fmt.Errorf("could not set config: %v", err)
		}
		return nil
	})
	log.Printf("Successfully Deleted Poll ID=%s from Bolt\n", id)
	return err
}

func GetPoll(db *bbolt.DB, id string) (Poll, error) {
	var err error
	var retrievedPoll = Poll{}
	err = db.View(func(tx *bbolt.Tx) error {
		bucket := tx.Bucket([]byte("DB")).Bucket(pollBucket)
		if bucket == nil {
			return err
		}

		json.Unmarshal(bucket.Get([]byte(id)), &retrievedPoll)

		return nil
	})
	log.Printf("Successfully retrieved Poll ID=%s from Bolt\n", id)
	return retrievedPoll, err
}

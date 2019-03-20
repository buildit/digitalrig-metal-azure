package database

import (
	"fmt"
	"github.com/buildit/slackbot/pkg/config"
	log "github.com/sirupsen/logrus"
	"go.etcd.io/bbolt"
)

var (
	DBCon *bbolt.DB
)

func OpenRead() (*bbolt.DB, error) {
	return openDB(true)
}

func OpenWrite() (*bbolt.DB, error) {
	return openDB(false)
}
func CloseDB() {
	DBCon.Close()
}

func openDB(readOnly bool) (*bbolt.DB, error) {
	db, err := bbolt.Open("slackbot.db", 0600, &bbolt.Options{ReadOnly: readOnly})
	if err != nil {
		return nil, fmt.Errorf("could not open db, %v", err)
	}

	err = db.Update(func(tx *bbolt.Tx) error {
		root, err := tx.CreateBucketIfNotExists([]byte("DB"))
		if err != nil {
			return fmt.Errorf("could not create root bucket: %v", err)
		}
		_, err = root.CreateBucketIfNotExists([]byte(config.Env.PollBucket))
		if err != nil {
			return fmt.Errorf("could not create POLL bucket: %v", err)
		}
		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("could not set up buckets, %v", err)
	}
	log.Println("DB Setup Done")
	return db, nil
}

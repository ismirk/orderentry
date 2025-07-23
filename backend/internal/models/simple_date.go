// internal/models/simple_date.go
package models

import (
	"database/sql/driver"
	"fmt"
	"time"
)

type SimpleDate struct {
	time.Time
}

const simpleDateLayout = "2006-01-02"

func (d *SimpleDate) UnmarshalJSON(b []byte) error {
	s := string(b)
	// Remove quotes
	if len(s) >= 2 && s[0] == '"' && s[len(s)-1] == '"' {
		s = s[1 : len(s)-1]
	}
	t, err := time.Parse(simpleDateLayout, s)
	if err != nil {
		return fmt.Errorf("invalid date format: %w", err)
	}
	d.Time = t
	return nil
}

func (d SimpleDate) Value() (driver.Value, error) {
	// Return the date as a string in "YYYY-MM-DD" format
	return d.Time.Format(simpleDateLayout), nil
}

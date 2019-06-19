// This script will check available helicopter flights from Vagar to Mykines
// every 10 minutes and print them to STDOUT.
package main

import (
	"github.com/antchfx/htmlquery"
	"log"
	"net/http"
	"net/http/cookiejar"
	"net/url"
	"os"
	"strings"
	"time"
)

const URL = "https://tyrla.atlantic.fo/"
const ENG_URL = "https://tyrla.atlantic.fo/Account/ChangeLocale/3"
const xpathToken = `//*[@id="bookingForm"]/input[1]`
const xpathID = `//*[@id="ChooseTripsViewModel_TripChoosen_OutboundTripId"]`

func getTrips() {
	jar, err := cookiejar.New(&cookiejar.Options{})
	if err != nil {
		log.Println(err)
		return
	}
	client := &http.Client{
		Jar: jar,
	}
	resp, err := client.Get(ENG_URL)
	if err != nil {
		log.Println(err)
		return
	}
	doc, err := htmlquery.Parse(resp.Body)
	if err != nil {
		log.Println(err)
		return
	}
	f := htmlquery.FindOne(doc, xpathToken)
	vToken := htmlquery.SelectAttr(f, "value")
	resp.Body.Close()

	formData := url.Values{
		"__RequestVerificationToken":             {vToken},
		"SearchCriteria.BookingType":             {"1"},
		"SearchCriteria.BookingAfterLimit":       {"false"},
		"SearchCriteria.FromHeliportId":          {"1"},
		"SearchCriteria.ToHeliportId":            {"2"},
		"SearchCriteria.FareTypeId":              {"1"},
		"SearchCriteria.DepartureDate":           {"26-07-2019"},
		"SearchCriteria.NumberOfPeople[0]":       {"1"},
		"SearchCriteria.NumberOfPeople[1]":       {"0"},
		"SearchCriteria.NumberOfPeople[2]":       {"0"},
		"SearchCriteria.NumberOfPeople[3]":       {"0"},
		"SearchCriteria.NumberOfPeople[4]":       {"0"},
		"SearchCriteria.Pieces":                  {"1"},
		"SearchCriteria.Weight":                  {""},
		"SearchCriteria.FreightRemarks":          {""},
		"SearchCriteria.SightSeingFromId":        {"13"},
		"SearchCriteria.SightSeeingDate":         {""},
		"SearchCriteria.SightSeeingPersonNumber": {"1"},
	}
	resp, err = client.PostForm(URL, formData)
	if err != nil {
		log.Println(err)
		return
	}
	doc, err = htmlquery.Parse(resp.Body)
	if err != nil {
		log.Println(err)
		return
	}

	var trips []string
	for _, n := range htmlquery.Find(doc, xpathID) {
		trips = append(trips, htmlquery.SelectAttr(n, "value"))
	}
	log.Printf("Found: %s\n", strings.Join(trips, ", "))
}

func main() {
	log.SetOutput(os.Stdout)
	ticker := time.NewTicker(10 * time.Minute)
	for {
		select {
		case <-ticker.C:
			getTrips()
		}
	}
}

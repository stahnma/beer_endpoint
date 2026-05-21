package main

import (
	"embed"
	"encoding/json"
	"flag"
	"fmt"
	"html/template"
	"io"
	"io/fs"
	"log"
	"net/http"
	"strings"
	"time"
)

const (
	tapsURL   = "https://docs.google.com/spreadsheets/d/1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY/export?format=tsv&gid=0"
	onDeckURL = "https://docs.google.com/spreadsheets/d/1SipVaaHNzAbI0F4C-wk_TPxxf8lVG4r4q-nqsI-uQhY/export?format=tsv&gid=382420153"
)

var defaultVals = [11]string{
	"Tap 16", "Temporarily", "Offline", "n/a", "n/a",
	"n/a", "empty", "1/12/1997", "empty", "1/12/1997", "n/a",
}

type Beer struct {
	Tap          string `json:"tap"`
	Brewery      string `json:"brewery"`
	BeerName     string `json:"beer_name"`
	Style        string `json:"style"`
	ABV          string `json:"abv"`
	IBU          string `json:"ibu"`
	Link         string `json:"link"`
	TapDate      string `json:"tap_date"`
	Vol          string `json:"vol"`
	DeliveryDate string `json:"delivery_date"`
	Origin       string `json:"origin"`
}

//go:embed views/index.html.tmpl
var tmplFS embed.FS

//go:embed public
var publicFS embed.FS

var indexTmpl = template.Must(
	template.New("index.html.tmpl").Funcs(template.FuncMap{
		"upper":    strings.ToUpper,
		"contains": strings.Contains,
	}).ParseFS(tmplFS, "views/index.html.tmpl"),
)

func validate(def, in string) string {
	if in == "" {
		return def
	}
	return in
}

func parseSheet(url string) ([]Beer, error) {
	resp, err := http.Get(url)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("sheet fetch %s: %s", url, resp.Status)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	text := strings.ReplaceAll(string(body), "\r\n", "\n")
	text = strings.ReplaceAll(text, "\r", "\n")
	lines := strings.Split(text, "\n")
	if len(lines) > 0 {
		lines = lines[1:] // drop header row
	}

	beers := make([]Beer, 0, len(lines))
	for _, line := range lines {
		if strings.TrimSpace(line) == "" {
			continue
		}
		fields := strings.Split(line, "\t")
		vals := make([]string, len(defaultVals))
		for i, def := range defaultVals {
			var v string
			if i < len(fields) {
				v = strings.TrimSpace(fields[i])
			}
			vals[i] = validate(def, v)
		}
		vals[4] = strings.ReplaceAll(vals[4], "%", "")
		beers = append(beers, Beer{
			Tap:          vals[0],
			Brewery:      vals[1],
			BeerName:     vals[2],
			Style:        vals[3],
			ABV:          vals[4],
			IBU:          vals[5],
			Link:         vals[6],
			TapDate:      vals[7],
			Vol:          vals[8],
			DeliveryDate: vals[9],
			Origin:       vals[10],
		})
	}
	return beers, nil
}

func writeJSON(w http.ResponseWriter, v any) {
	w.Header().Set("Content-Type", "application/json")
	if err := json.NewEncoder(w).Encode(v); err != nil {
		log.Printf("encode json: %v", err)
	}
}

func indexHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/" {
		http.NotFound(w, r)
		return
	}
	beers, err := parseSheet(tapsURL)
	if err != nil {
		log.Printf("parseSheet taps: %v", err)
		http.Error(w, "failed to load tap list", http.StatusBadGateway)
		return
	}
	data := struct {
		Kegerator []Beer
		Year      int
	}{
		Kegerator: beers,
		Year:      time.Now().Year(),
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	if err := indexTmpl.Execute(w, data); err != nil {
		log.Printf("template execute: %v", err)
	}
}

func beerHandler(w http.ResponseWriter, r *http.Request) {
	beers, err := parseSheet(tapsURL)
	if err != nil {
		log.Printf("parseSheet taps: %v", err)
		http.Error(w, "failed to load tap list", http.StatusBadGateway)
		return
	}
	writeJSON(w, beers)
}

func onDeckHandler(w http.ResponseWriter, r *http.Request) {
	beers, err := parseSheet(onDeckURL)
	if err != nil {
		log.Printf("parseSheet ondeck: %v", err)
		http.Error(w, "failed to load on-deck list", http.StatusBadGateway)
		return
	}
	writeJSON(w, beers)
}

func main() {
	addr := flag.String("addr", ":8334", "listen address")
	flag.Parse()

	pub, err := fs.Sub(publicFS, "public")
	if err != nil {
		log.Fatalf("public fs: %v", err)
	}

	mux := http.NewServeMux()
	mux.HandleFunc("/", indexHandler)
	mux.HandleFunc("/api/v1/beer", beerHandler)
	mux.HandleFunc("/api/v1/ondeck", onDeckHandler)
	mux.Handle("/favicon.ico", http.FileServer(http.FS(pub)))
	mux.Handle("/style.css", http.FileServer(http.FS(pub)))
	mux.Handle("/puppet_mark.png", http.FileServer(http.FS(pub)))

	log.Printf("listening on %s", *addr)
	if err := http.ListenAndServe(*addr, mux); err != nil {
		log.Fatal(err)
	}
}

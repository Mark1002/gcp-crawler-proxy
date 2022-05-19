package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/exec"
)

type Data struct {
	IP string `json:"ip"`
}

type Resp struct {
	Status  string `json:"status"`
	Message string `json:"message"`
}

func main() {
	http.HandleFunc("/rotate_proxy", scriptHandler)

	// Determine port for HTTP service.
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("Defaulting to port %s", port)
	}

	// Start HTTP server.
	log.Printf("Listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func scriptHandler(w http.ResponseWriter, r *http.Request) {
	if r.URL.Path != "/rotate_proxy" {
		http.Error(w, "404 not found.", http.StatusNotFound)
		return
	}
	switch r.Method {
	case "GET":
		fmt.Fprintf(w, "invalid")
	case "POST":
		reqBody, _ := ioutil.ReadAll(r.Body)
		var resp Resp
		var data Data
		json.Unmarshal(reqBody, &data)
		cmd := exec.CommandContext(r.Context(), "/bin/sh", "rotate_proxy.sh", data.IP)
		cmd.Stderr = os.Stderr
		out, err := cmd.Output()
		if err != nil {
			w.WriteHeader(500)
			resp.Status = "error"
		} else {
			w.WriteHeader(http.StatusCreated)
			resp.Status = "ok"
		}
		w.Header().Set("Content-Type", "application/json")
		resp.Message = string(out)
		jsonResp, _ := json.Marshal(resp)
		w.Write(jsonResp)
	default:
		fmt.Fprintf(w, "Sorry, only GET and POST methods are supported.")
	}
}

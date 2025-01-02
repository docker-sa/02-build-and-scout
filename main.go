package main

import (
    "fmt"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintln(w, "Hola, Mundo!")
}

func main() {
    http.HandleFunc("/", handler)
    fmt.Println("Server listening on port 80...")
    if err := http.ListenAndServe(":80", nil); err != nil {
        fmt.Println("Error starting server:", err)
    }
}

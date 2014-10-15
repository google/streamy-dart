package main

import (
  "archive/tar"
  "compress/gzip"
  "net/http"
  "path/filepath"
  "log"
  "io"
  "os"
  "strings"
)

func filter(path string) bool {
  parts := strings.Split(path, "/")
  if parts[0] == ".git" || parts[0] == "pubspec.lock" || parts[0] == "packages" {
    return false
  }
  if parts[len(parts) - 1] == "packages" {
    return false
  }
  return true
}

func TarHandler(resp http.ResponseWriter, req *http.Request) {
  resp.Header().Add("Content-Type", "application/octet-stream")
  gz := gzip.NewWriter(resp)
  defer gz.Close()
  tw := tar.NewWriter(gz)
  defer tw.Close()
  filepath.Walk(".", func(path string, info os.FileInfo, err error) error {
    if err != nil {
      log.Fatalf("Walk error: %s", err)
    }
    if !filter(path) {
      return nil
    }
    h, err := tar.FileInfoHeader(info, "")
    if err != nil {
      log.Fatalf("FileInfoHeader Error: %s", err)
    }
    h.Name = path
    err = tw.WriteHeader(h)
    if err != nil {
      log.Fatalf("Tar WriteHeader Error: %s", err);
    }
    if !info.Mode().IsRegular() {
      return nil
    }
    f, err := os.Open(path)
    if err != nil {
      log.Fatalf("OpenError: %s", err)
    }
    defer f.Close()
    _, err = io.Copy(tw, f)
    if err != nil {
      log.Fatalf("CopyError: %s", err)
    }
    return nil
  })
}

func main() {
  http.HandleFunc("/streamy.tar.gz", TarHandler)
  err := http.ListenAndServe(":8080", nil)
  if err != nil {
    log.Fatalf("Failed to start server: %s", err)
  }
}

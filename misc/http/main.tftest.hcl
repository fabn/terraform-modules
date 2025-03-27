run "parsed" {
  variables {
    url = "https://jsonip.com"
  }

  assert {
    condition     = output.status_code == 200
    error_message = "Wrong status code returned"
  }

  assert {
    condition     = length(output.parsed.ip) > 0
    error_message = "JSON body not parsed"
  }

  assert {
    condition     = regex("json", output.headers["Content-Type"]) == "json"
    error_message = "Wrong header matching"
  }
}

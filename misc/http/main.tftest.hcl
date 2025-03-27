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
    condition     = strcontains(output.headers["Content-Type"], "json")
    error_message = "Wrong header matching"
  }
}

run "with_complex_json" {
  variables {
    url = "https://jsonplaceholder.typicode.com/todos" # Returns a list of objects
  }
}

run "not_found" {
  variables {
    url          = "https://example.com/not-found"
    status_codes = [404]
  }

  assert {
    condition     = output.status_code == 404
    error_message = "Wrong status code returned"
  }

  assert {
    condition     = output.parsed == {}
    error_message = "Parsed body should be empty"
  }
}

// Pacto Contracts describe the constraints we want to put on interactions between a consumer and a provider.  It sets some expectations about the headers expected for both the request and response, the expected response status code.  It also uses [json-schema](http://json-schema.org/) to define the allowable request body (if one should exist) and response body.
{
  // The Request section comes first.  In this case, we're just describing a simple get request that does not require any parameters or a request body.
  "request": {
    "headers": {
      // A request must exactly match these headers for Pacto to believe the request matches the contract, unless `Pacto.configuration.strict_matchers` is false.
      "Accept": "application/vnd.github.beta+json",
      "Accept-Encoding": "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
    },
    // The `method` and `path` are required.  The `path` may be an [rfc6570 URI template](http://tools.ietf.org/html/rfc6570) for more flexible matching.
    "method": "get",
    "path": "/repos/thoughtworks/pacto/readme"
  },
  "response": {
    "headers": {
      "Content-Type": "application/json; charset=utf-8",
      "Status": "200 OK",
      "Cache-Control": "public, max-age=60, s-maxage=60",
      "Etag": "\"fc8e78b0a9694de66d47317768b20820\"",
      "Vary": "Accept, Accept-Encoding",
      "Access-Control-Allow-Credentials": "true",
      "Access-Control-Expose-Headers": "ETag, Link, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval",
      "Access-Control-Allow-Origin": "*"
    },
    "status": 200,
    "body": {
      "$schema": "http://json-schema.org/draft-03/schema#",
      "description": "Generated from https://api.github.com/repos/thoughtworks/pacto/readme with shasum 3ae59164c6d9f84c0a81f21fb63e17b3b8ce6894",
      "type": "object",
      "required": true,
      "properties": {
        "name": {
          "type": "string",
          "required": true
        },
        "path": {
          "type": "string",
          "required": true
        },
        "sha": {
          "type": "string",
          "required": true
        },
        "size": {
          "type": "integer",
          "required": true
        },
        "url": {
          "type": "string",
          "required": true
        },
        "html_url": {
          "type": "string",
          "required": true
        },
        "git_url": {
          "type": "string",
          "required": true
        },
        "type": {
          "type": "string",
          "required": true
        },
        "content": {
          "type": "string",
          "required": true
        },
        "encoding": {
          "type": "string",
          "required": true
        },
        "_links": {
          "type": "object",
          "required": true,
          "properties": {
            "self": {
              "type": "string",
              "required": true
            },
            "git": {
              "type": "string",
              "required": true
            },
            "html": {
              "type": "string",
              "required": true
            }
          }
        }
      }
    }
  }
}
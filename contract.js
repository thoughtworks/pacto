// A Pacto Contract is a json document that describes an expected interaction between a consumer and provider,
// by describing the expected format of the HTTP request/response they will exchange.  Currently, Pacto Contracts
// are only supported for HTTP services using JSON.
// 
// Pacto contracts make use of [json-schema](http://json-schema.org/) to define and validate
// the request and response bodies, and support []
{
  // The request is described first.  Pacto may use this in order to:
  // - Send a sample request to a provider so the response can be validated.
  // - Validate a request sent by a consumer.
  // - Match a request from a consumer in order to return a stub response.
  "request": {
    // The headers section describes [HTTP request headers](http://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Requests)
    // that are normally part of the request.  In stricter modes, the actual headers must match the values in the contract in order
    // for a service to be validated or stubbed.
    "headers": {
      "Accept": "application/vnd.github.beta+json",
      "Accept-Encoding": "gzip;q=1.0,deflate;q=0.6,identity;q=0.3"
    },
    // The [HTTP method](http://www.w3.org/Protocols/rfc2616/rfc2616-sec9.html) used to
    // send a sample request to a provider, or match a consumer request for stubbing.
    "method": "get",
    // The path portion of the URL.  [RFC #6570](http://tools.ietf.org/html/rfc6570) URI templates are supported for
    // stubbing, but not for creating sample requests.
    "path": "/repos/thoughtworks/pacto/readme"
  },
  // The response section may be used to:
  // - Create a stubbed response.
  // - Validate a response sent by a provider (for sample or real consumer requests).
  "response": {
    // The headers section describes [HTTP response headers](http://en.wikipedia.org/wiki/List_of_HTTP_header_fields#Responses)
    // that are normally sent during the response.  In stricter modes, the actual headers must match the expected values in this
    // contract, or the response will be considered invalid.
    "headers": {
      "Content-Type": "application/json; charset=utf-8",
      // Note: this Status response header is in addition to the status code sent as part of an HTTP response.
      // Most services do not send this.
      "Status": "200 OK",
      "Cache-Control": "public, max-age=60, s-maxage=60",
      "Etag": "\"d52cb23e9b05c6af619094a00fb5da46\"",
      // Multiple values can be specified with an array.
      // The Vary header is used when generating contracts, in order to decide which request
      // headers should be kept.  Request headers that are not in this list will be discarded.
      "Vary": [
        "Accept",
        "Accept-Encoding"
      ],
      "Access-Control-Allow-Credentials": "true",
      "Access-Control-Expose-Headers": "ETag, Link, X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset, X-OAuth-Scopes, X-Accepted-OAuth-Scopes, X-Poll-Interval",
      "Access-Control-Allow-Origin": "*"
    },
    // The HTTP status code for stubbing and validation.
    "status": 200,
    // The body is a [json-schema](http://json-schema.org/) description of the HTTP response body.
    "body": {
      // Currently, only json-schema draft-03 is supported.
      "$schema": "http://json-schema.org/draft-03/schema#",
      // The generator creates these comments so it is easier to diff a change and see if the
      // contract was regenerated or edited by hand.
      "description": "Generated from vcr with shasum 3ae59164c6d9f84c0a81f21fb63e17b3b8ce6894",
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

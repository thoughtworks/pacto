@needs_server
Feature: Contract Generation

  We know - json-schema can get pretty verbose!  It's a powerful tool, but writing the entire Contract by hand for a complex service is a painstaking task.  We've created a simple generator to speed this process up.  You can invoke it programmatically, or with the provided rake task.

  You just need to create a partial Contract that only describes the request.  The generator will then execute the request, and use the response to generate a full Contract.

  Remember, we only record request headers if they are in the response's [Vary header](http://www.subbu.org/blog/2007/12/vary-header-for-restful-applications), so make sure your services return a proper Vary for best results!

  Background:
    Given a file named "requests/my_contract.json" with:
    """
        {
        "request": {
          "method": "GET",
          "path": "/hello",
          "headers": {
            "Accept": "application/json"
          }
        },
        "response": {
          "status": 200,
          "body": {
            "required": true
          }
        }
      }
    """

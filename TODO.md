# TODO

## Nice to have

- Cucumber Tests as docs (see https://relishapp.com/cucumber/cucumber/docs/);
- Fake Server (sinatra app generating fake responses based on the contracts);
- Optional "require" format for JSON Schema: # 'required': ['id', 'categorias', 'titulo', ...];
- Contract variables for easy writing. Such as: 'path': '/member/{id}';
- Add JSHint rake task to validate contracts syntax;
- Pretty output for hash difference (using something like [hashdiff](https://github.com/liufengyun/hashdiff)).
- A default header in the response marking the response as "mocked"
- Parameter matcher should use an idea of "subset" instead of matching all the parameters
- 'default' value to be used when it is present with an array of types
- Support 'null' attribute type
- Validate contract structure in a rake task. Then assume all contracts are valid.
- When a request is not OK (200), the body may not be a json. Add support to ignore the body.

## Assumptions

- JSON Schema references are stored in the 'definitions' attribute, in the schema's root element.

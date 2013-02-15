# TODO

## Nice to have

- Cucumber Tests as docs (see https://relishapp.com/cucumber/cucumber/docs/);
- Fake Server (sinatra app generating fake responses based on the contracts);
- Optional "require" format for JSON Schema: # 'required': ['id', 'categorias', 'titulo', ...];
- Contract variables for easy writing. Such as: 'path': '/member/{id}';
- Add JSHint rake task to validate contracts syntax;
- Pretty output for hash difference (using something like [hashdiff](https://github.com/liufengyun/hashdiff)).
- A default header in the response marking the response as "mocked"

## Assumptions

- JSON Schema references are stored in the 'definitions' attribute, in the schema's root element.

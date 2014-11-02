# TODO

# v0.4

## Thor
- Kill rake tasks, replace w/ pacto binary
- Split Pacto server to separate repo??

## Swagger converter
- Legacy contracts -> Swagger

## Swagger concepts not yet supported by Pacto
- Support schemes (multiple)
- Support multiple report types
- Validate parameters
- Support Swagger formats/serializations
- Support Swagger examples, or extension for examples

## Documentation

- Polytrix samples -> docs

# v0.5

## Swagger
- Support multiple media types (not just JSON)
- Extension: templates for more advanced stubbing
- Patterns: detect creation, auto-delete
- Configure multiple producers: pacto server w/ multiple ports

# v0.6

## Nice to have


# Someday

- Pretty output for hash difference (using something like [hashdiff](https://github.com/liufengyun/hashdiff)).
- A default header in the response marking the response as "mocked"

## Assumptions

- JSON Schema references are stored in the 'definitions' attribute, in the schema's root element.

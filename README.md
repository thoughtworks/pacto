# Contracts

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'contracts'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install contracts

## Usage

TODO: Write usage instructions here

## TODO

Nice to have
------------
- Cucumber Tests as docs (see https://relishapp.com/cucumber/cucumber/docs/)
- Fake Server (sinatra app accepting the contracts)
- Dereferenciator
- optional "require"format: # 'required': ['id', 'categorias', 'titulo', ...]
- contract variables for easy writing. Such as: 'path': '/member/{id}'
- add JSHinnt / JSLint to the rake task to validate contracts

- ref pode apontar para qualquer definição, o nome da definição não precisa ser 'definitions'
- selecionar o mock mais especifico quando comparando requisições
- ainda não implementado a comparação do 'header' e do 'method' para selecionar o mock

Suposições
----------
- todas definições estão no atributo chamado 'definitions' na raíz do schema


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

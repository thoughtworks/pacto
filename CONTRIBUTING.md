# Contributing

You are welcome to contribute to Pacto and this guide will help you to:

- [Setup](#setup) all the needed dependencies in order to start hacking.
- Follow [conventions](#code-conventions) agreed among the project 
contributors.
- Follow Pacto's suggested [workflow](#workflow).
- [Submit](#submit-code) new code to the project.
- Run the automated suite of [tests](#run-tests) that is bundled with Pacto.
- Find easily code annotations for [technical debt](#technical-debt) (TODOs,
FIXMEs, etc)
- Be aware of some [troubleshooting tips](#troubleshooting) when running issues
with Pacto.

## <a name="workflow"></a>Development (suggested) workflow

Pacto comes with [`guard`](https://github.com/guard/guard) enabled, this means
that guard will trigger the tests after any change is made on the source code.
We try to keep the feedback loop as fast as we can, so you can be able to run
all the tests everytime you make a change on the project. If you want to follow
this workflow just run:

`bundle exec guard`

Guard will run first the static analysis and then will run the unit test related
with the file that was changed, later the integration test and last the user
journey tests.

## <a name="submit-code"></a>Submit code

Any contribution has to come from a Pull Request via GitHub, to do it just
follow these steps:

1. Fork it (`git clone git@github.com:thoughtworks/pacto.git`).
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Verify that the tests are passing (`bundle exec rake`).
5. Push to the branch (`git push origin my-new-feature`).
6. Create new Pull Request.

## <a name="setup"></a>Setting up

You will need to have installed:

- Ruby 1.9.3 or greater installed.
- Bundler gem installed (`gem install bundler`).
- Install all the dependencies (`bundle install`).

## <a name="code-conventions"></a>Coding conventions

### Style guide

Contributing in a project among several authors could lead to different styles
of writting code. In order to create some basic baseline on the source code
Pacto comes with an static code analyzer that will enforce the code to follow
the [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide). To execute
the analyzer just run:

`bundle exec rubocop`

### Writing tests

Pacto unit tests and integration test are written in RSpec and the user journey
tests are written in Cucumber. For the RSpec tests we suggest to follow the
[Better Specs](http://betterspecs.org/) guideline.

## <a name="run-tests"></a>Running tests

Pacto comes with a set of automated tests. All the tests are runnable via rake
tasks:

- Unit tests (`bundle exec rake unit`).
- Integration tests (`bundle exec rake integration`).
- User journey tests (`bundle exec rake journey`).

It is also possible run specific tests:

- Unit tests (`bundle exec rspec spec/unit/[file_path]`
- Integration tests  (`bundle exec rspec spec/integration/[file_path]`)
- User journey tests (`bundle exec cucumber features/[file_path] -r features/support/env.rb`)

### Checking that all is green

To know that both tests and static analysis is working fine you just have to
run:

`bundle exec rake`

## <a name="technical-debt"></a>Technical Debt

Some of the code in Pacto is commented with the anotations TODO or
FIXME that might point to some potencial technical debt on the source code. If
you are interested to list where are all these, just run:

`bundle exec notes`

## <a name="troubleshooting"></a>Troubleshooting

### Debugging pacto

If you run into some strange behaviour that Pacto might have, you can take
advantage of the debugging capabilities of Pacto. Running the tests with the
environment variable PACTO_DEBUG=true will show (on the standard output) more
details what Pacto is doing behind the scenes.

### Gemfile.lock

Because Pacto is a gem we don't include the Gemfile.lock into the repository
([here is the reason](http://yehudakatz.com/2010/12/16/clarifying-the-roles-of-the-gemspec-and-gemfile/)).
This could lead to some problems in your daily job as contributor specially
when there is an upgrade in any of the gems that Pacto depends upon. That is
why we recomend you to remove the Gemfile.lock and generate it
(`bundle install`) everytime there are changes on the dependencies.


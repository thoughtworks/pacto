# Standalone server
You can run Pacto as a server in order to test non-Ruby projects. In order to get the full set
of options, run:

```sh
bundle exec pacto-server -h
```

You probably want to run with the -sv option, which will display verbose output to stdout. You can
run server that proxies to a live endpoint:

```sh
bundle exec pacto-server -sv --port 9000 --live http://example.com &
bundle exec pacto-server -sv --port 9001 --stub &

pkill -f pacto-server
```


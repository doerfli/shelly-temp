# Shelly-temp

This is a simple ruby on rails webapplication to received URL action event from a Shelly H&T device and display the temperature on a webpage. 

## Start application


Create and migrate database

```
bundle exec rake db:create
bundle exec rake db:migrate
```

Run server

```
bundle exec rails start
```

## Configuration

Point your shelly to `http://<hostname>:<port>/measurements/new`

**Important** Shelly does not support https targets!!!

Once at least one event was sent, open a webbrowser to `http://<hostname>:<port>/displays/<deviceid>`


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

## Start development server

Start dev-server, css build, js build

```
bin/dev
yarn build:css --watch
yarn build --watch
```

## Configuration

Point your shelly to `http://<hostname>:<port>/measurements/new`

**Important** Shelly does not support https targets!!!

Once at least one event was sent, open a webbrowser to `http://<hostname>:<port>/displays/<deviceid>`

## Test request

```
curl "http://localhost:3000/measurements/new?id=device01&temp=21.23&hum=58.34"
```

# Door Relay API

This repository manages a NCD relay thats connected via USB, and is controlled by a ruby rack HTTP server.

* Controls relays via HTTP requests to open/close door strikes
* Returns result object to return to the request client
* Logs each request

### Requirements

* Ruby 2.5.1
* Ruby Bundler
* Nginx Proxy
* SQLite3 Installed

### Configuration

Setup a new configuration file by coping `config.example.yml` to `config.yml`.

* `debug` Disables the connection to the serial device, mocks `Relay`.
* `logging.database` The SQLite3 database to log requests.
* `relay.file` The location to the usb/serial file.

---

## Sending a Relay Reuqest

Sending a request to turn relay '1' to 'on', or 'closed'.

Send a simple POST request, with parameters `relay` to indicate the index of the relay (1-8) and `command` to indicate whether you want the relay to turn `on` ( closed circuit ) or `off` ( open circuit ), and `scan_id` as the scan ID from the API.

```ruby
require 'uri'
require 'net/http'

url = URI("http://10.10.1.34")

http = Net::HTTP.new(url.host, url.port)

request = Net::HTTP::Post.new(url)
request["content-type"] = 'multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW'
request["Cache-Control"] = 'no-cache'
request["Postman-Token"] = '826d0180-173c-43d7-acda-241ab50d0bc1'
request.body = "------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"relay\"\r\n\r\n1\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"command\"\r\n\r\nstatus\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW\r\nContent-Disposition: form-data; name=\"scan_id\"\r\n\r\n123\r\n------WebKitFormBoundary7MA4YWxkTrZu0gW--"

response = http.request(request)
puts response.read_body
```
(copied from postman)

---
## Logging

Logging is sent to a local sqlite database.

## Systemd Service

The ruby HTTP Rack Server is controlled via:

`/door-relay-server $ ./bin/server`

Although you probably don't want to use this command, as its managed by `systemd` via the service configuration in `/server/app.service`.

Use `systemd` commands to manage the server. In order for the service to be managed by `systemd` link `/server/app.service` to `/etc/systemd/system/app.service` and `/etc/systemd/system/multi-user.target.wants/app.service`.

To start the HTTP Server:

`sudo systemctl start app`

To check the status of the HTTP Server Service:

`sudo systemctl status app`

To restar the HTTP Sever:

`sudo systemctl restart app`

## Nginx Configuration

The nginx configuration simply proxies the requests from to `localhost:8080` which is what the ruby HTTP server is binded too.
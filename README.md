beer_endpoint
=============

Beer Endpoint for Kegs at Puppet.

The production deployment can normally be found at [https://puppet.com/beer](https://puppet.com/beer)

# How does it work?

This works through a very complex system of talking to a google spreadsheet and
reading cells. The sheet needs to look a certain way, or this whole thing falls
apart. Is this useful outside of Puppet? Maybe, but it might require
edits.

# Build & Run

This is a single static Go binary. The HTML template and static assets are
embedded, so the binary has no runtime file dependencies.

## Build

  `make build`

or directly:

  `go build -o beer_endpoint .`

## Run

  `./beer_endpoint`

The server listens on `:8334` by default. Override with `-addr`:

  `./beer_endpoint -addr :9000`

# Endpoints

  * `GET /` — HTML view of what's on tap
  * `GET /api/v1/beer` — JSON of what's on tap
  * `GET /api/v1/ondeck` — JSON of what's on deck

# Edits

If you'd like to fix/improve anything, please do.

# License

  * [WTFPL](http://www.wtfpl.net/) -- See LICENSE File for more infromation.

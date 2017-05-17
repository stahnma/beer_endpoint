beer_endpoint
=============

Beer Endpoint for Kegs at Puppet.

The production deployment can normally be found at [https://puppet.com/beer](https://puppet.com/beer)

# How does it work?

This works through a very complex system of talking to a google spreadsheet and
reading cells. The sheet needs to look a certain way, or this whole thing falls
apart. Is this useful outside of Puppet? Maybe, but it might require
edits.

# Actual Deployment

Wow, I still hate ruby deployments. In order to "solve" the deployment problem, I'm trying out docker here.

## Build the Docker image

  `make image`


## Run the Docker image


  `make run`


## View the logs


If you're using my makefile for shortcuts, then your container will be named
beer_endpoint.

  `docker logs beer_endpoint`


## Clean up your mess

  `make clean`

This will stop the running container and remove it from your system. This is
nice when doing development and iterating.


# Edits

If you'd like to fix/improve anything, please do. I'm hoping the docker model
makes this a little easier for people doing development to send up UI fixes or
patches or whatnot.

# License

  * [WTFPL](http://www.wtfpl.net/) -- See LICENSE File for more infromation.

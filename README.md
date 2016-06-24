## Private Tor Network on Docker

##### An isolated, private tor network running entirely in Docker containers

### Quickstart

The easiest way to get a tor network up and running is to use the docker-compose scale function:

`docker-compose scale da=3 relay=5 exit=3 client=1`

### Network Settings

All of the requisit information that other nodes need to know about on the network are stored in a mapped volume: `./tor:/tor`. NOTE: This folder must exist on the host and allow the debian-tor user to create files in this directory. 

### Running Individual Roles

This is building a base tor relay container and then modifying it based on ROLE environment variable you give it. For example, this would make a directory authority (DA)
`docker run -e ROLE=DA antitree/tor-private-server`

Available roles right now are:

* DA - directory authority
* RELAY - non-exit relay
* EXIT - exit relay
* CLIENT - exposes the tor socks port on 9050 to the host

### Tor configuration

This configuration is based on the Tor documentation for how to run a private tor network. You should also check out Chutney[1] which does something similar with separate processes instead of containers. 

### Debugging

Here are a few things to try if you're runing into issues:

* Check the tor logs sent to stdout `docker logs -f torserver_da_1`
* Check all the logs with `docker-compose logs`
* Enable verbose logging by changing the `./config/torrc` 
* Check permissions for your ./tor folder
* Delete the files in your ./tor folder so you can start from scratch (or specifically the torrc.da file)

### References

- https://github.com/chriswayg/tor-server
- https://www.torproject.org/docs/tor-relay-debian.html.en

[1]: https://gitweb.torproject.org/chutney.git/



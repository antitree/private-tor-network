## Private Tor Network on Docker

##### An isolated, private tor network running entirely in Docker containers

### Quickstart

The easiest way to get a tor network up and running is to use the docker-compose create and then scale function

```
docker-compose up 
docker-compose scale relay=5 exit=3 
```

This will create 3 directory authorities (DA's), 1 client listning on port 9050, 5 relays, and 3 exits. You can scale to whatever you want. 

### Uses

If you're going "Why do I want this?" here's a few examples:

*tor research*: learn how tor interacts with nodes, make modifications to settings and see what happens, understand how the Tor Network operates without affecting real people. (Originally this project was part of a class I wrote to teach about how tor works)

*tor development*: in the case you're working on a patch that is more complex and requires seeing what happens on the tor network, you can apply the patches to the containers.

*traffic analysis*: Test out the latest tor exploit and pretend to be a nation state adversary.

### Network Settings

All of the required information that other nodes need to know about on the network are stored in a mapped volume: `./tor:/tor`. (I know you shouldn't do this but I needed it for a class) NOTE: This folder must exist on the host and allow the debian-tor user to create files in this directory. 

### Running Individual Roles

This is building a base tor relay container and then modifying it based on ROLE environment variable you give it. For example, this would make a directory authority (DA)
`docker run -e ROLE=DA antitree/tor-private-server`

Available roles right now are:

* DA - directory authority
* RELAY - non-exit relay
* EXIT - exit relay
* CLIENT - exposes the tor socks port on 9050 to the host

### Tor configuration

This configuration is based on the Tor documentation for how to run a private tor network. You should also check out Chutney[1] which does something similar with separate processes instead of containers. If you need to make a modification (such as changing the timing of the DA's) edit the `config/torrc` and/or `config/torrc.da` files. You may need to modify the Dockerfile as well. 

### Debugging

Here are a few things to try if you're runing into issues:

* Check the tor logs sent to stdout `docker logs -f torserver_da_1`
* Check all the logs with `docker-compose logs`
* Enable verbose logging by changing the `./config/torrc` 
* Check permissions for your ./tor folder
* Delete the files in your ./tor folder so you can start from scratch (or specifically the torrc.da file)
* To cleanup the environment and start over you can use `docker-compose kill` and `docker-compose rm -ra` to remove them all. 

### TODO

* Use an environment variable to choose which version of tor to compile
* Get rid of apt-get from docker container
* Wait for someone to yell at me about using scale like this and then move to the new networking

### Dislaimer

This project is in no way associated with the Tor Project or their developers. Like many people I'm a fan of Tor and recommend considering ways you can help the project. Consider running a relay, donating, or writing code. 

### References

- https://github.com/chriswayg/tor-server
- https://www.torproject.org/docs/tor-relay-debian.html.en

[1]: https://gitweb.torproject.org/chutney.git/



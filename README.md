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

**tor research**: learn how tor interacts with nodes, make modifications to settings and see what happens, understand how the Tor Network operates without affecting real people. Originally this project was part of a class I wrote to teach about how tor works.

**tor development**: in the case you're working on a patch that is more complex and requires seeing what happens on the tor network, you can apply the patches to the containers.

**traffic analysis**: Test out the latest tor exploit and pretend to be a nation state adversary.

*If this needs to be said, this should never be used as a replacement for tor. This is for research purposes alone.*

### Network Settings

All of the required information that other nodes need to know about on the network are stored in a mapped volume: `./tor:/tor`. (I know you shouldn't do this but I needed it for a class) NOTE: This folder must exist on the host and allow the debian-tor user to create files in this directory. 

### Running Individual Roles

You can manually build a tor network if you don't want to use docker-compose but you'll need to make sure you pass the correct DA fingerprints to each of the servers. (Don't for you automatically with docker-compose) For example, this would make the first directory authority (DA)
`docker run -e ROLE=DA antitree/private-tor`

Or setup a relay:
`docker run -e ROLE=RELAY antitree/private-tor`

Watching the logs on a relay
`docker logs -f {name of your container}`

Available roles right now are:

* DA - directory authority
* RELAY - non-exit relay
* EXIT - exit relay
* CLIENT - exposes the tor socks port on 9050 to the host

### Tor configuration

This configuration is based on the Tor documentation for how to run a private tor network. You should also check out [Chutney](https://gitweb.torproject.org/chutney.git/) which does something similar with separate processes instead of containers. If you need to make a modification (such as changing the timing of the DA's) edit the `config/torrc` and/or `config/torrc.da` files. You may need to modify the Dockerfile as well.

### Environment variables

The container is built off of [chriswayg/tor-server](https://github.com/chriswayg/tor-server) but has been heavily modified to support some other env variables that you can pass to it:

* TOR_ORPORT - default is 7000
* TOR_DIRPORT - default is 9030
* TOR_DIR - container path to mount a persistent tor material. default is /tor
* TOR_CONTROL_PWD - set the control port password to something besides "password"

### Using With arm

With the tor control port exposed to the host, you can use arm to monitor the client. 
```
apt-get install tor-arm
arm
```
NOTE: There is a password to protect the control port right now. Enter "password" when prompted

![arm screenshot](https://raw.githubusercontent.com/antitree/private-tor-network/master/doc/arm.png)

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

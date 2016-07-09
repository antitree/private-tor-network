from stem.control import Controller

with Controller.from_port(port = 9051) as controller:
  controller.authenticate("password")

  print("List of relays found on the network:")
  for desc in controller.get_network_statuses():
    print("%s (%s) at %s" % (desc.nickname, desc.fingerprint, desc.address))

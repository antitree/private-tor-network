# Connects to the control port to test that the private network is working
import sys
import getpass
import stem.connection
import stem.socket

try:
  control_socket = stem.socket.ControlPort(port = 9051)
except stem.SocketError as exc:
  print 'Unable to connect to port 9051 (%s)' % exc
  sys.exit(1)

try:
  stem.connection.authenticate(control_socket)
except stem.connection.IncorrectSocketType:
  print 'Please check in your torrc that 9051 is the ControlPort.'
  print 'Maybe you configured it to be the ORPort or SocksPort instead?'
  sys.exit(1)
except stem.connection.MissingPassword:
  controller_password = getpass.getpass('Controller password: ')

  try:
    stem.connection.authenticate_password(control_socket, controller_password)
  except stem.connection.PasswordAuthFailed:
    print 'Unable to authenticate, password is incorrect'
    sys.exit(1)
except stem.connection.AuthenticationFailure as exc:
  print 'Unable to authenticate: %s' % exc
  sys.exit(1)

print("Successfully authenticated")

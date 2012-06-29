# Use a secret to create a signature for any data.
#
# This method is commonly used for secure cookies. Rails does this, for
# example. The cookie data is public. A method like the one described here
# is used to create a signature based on a secret when the cookie is created.
# The actual cookie contains the cookie data itself, and the signature. When
# the framework receives a cookie, it creates a new signature for the cookie.
# If either the cookie data or the signature data changed, you know someone
# tampered with the cookie. The security lies in that only the ones that know
# the secret are able to create the correct signature.

require "openssl"

data = "This is some data"
secret = "cfa4f9980a2209f91145d912082dcbfd28484e4fe846df404ef417b57aae740b880820fe357b99e7"
signature = OpenSSL::HMAC.digest("sha1", secret, data)

payload = {:data => data, :signature => signature}

# Now send the payload to anyone.

# If the payload is not tampered with:
p payload[:signature] == OpenSSL::HMAC.digest("sha1", secret, payload[:data])
# => true

# If someone tampers with the signature or data, you'll know, because the
# signatures won't match

p payload[:signature] + "altered" == OpenSSL::HMAC.digest("sha1", secret, payload[:data])
# => false
p payload[:signature] == OpenSSL::HMAC.digest("sha1", secret, payload[:data] + "altered")
# => false

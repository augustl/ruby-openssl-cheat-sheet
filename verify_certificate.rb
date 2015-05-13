require "openssl"

my_cert = OpenSSL::X509::Certificate.new(File.read("my-cert.pem"))
ca_cert = OpenSSL::X509::Certificate.new(File.read("ca-cert.pem"))

# True if my-cert.pem was signed by ca-cert.pem, otherwise false.
p my_cert.verify(ca_cert.public_key)

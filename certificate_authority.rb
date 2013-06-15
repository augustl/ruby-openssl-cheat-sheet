# This is not for the faint of heart.
#
# TODO: Add a ton of explanation here.

require "openssl"


# Generating the CA is a one time only operation. Once you have the private
# key and certificate files, you will reuse those for future signing
# operations
ca_passphrase = "verysecret"
ca_keypair = OpenSSL::PKey::RSA.new(2048)
File.open("/tmp/ca.pem", "w+") do |f|
  f.write ca_keypair.to_pem(OpenSSL::Cipher.new("AES-128-CBC"), ca_passphrase)
end

ca_cert = OpenSSL::X509::Certificate.new
ca_cert.not_before = Time.now
ca_cert.subject = OpenSSL::X509::Name.new([
    ["C", "NO"],
    ["ST", "Oslo"],
    ["L", "Oslo"],
    ["O", "August Lilleaas"]
  ])
# All issued certs will be unusuable after this time.
ca_cert.not_after = Time.now + 1000000000 # 40 or so years
ca_cert.serial = 1
ca_cert.public_key = ca_keypair.public_key
ef = OpenSSL::X509::ExtensionFactory.new
ef.subject_certificate = ca_cert
ef.issuer_certificate = ca_cert
ca_cert.add_extension(ef.create_extension("basicConstraints", "CA:TRUE", true))
ca_cert.add_extension(ef.create_extension("keyUsage","keyCertSign, cRLSign", true))
ca_cert.add_extension(ef.create_extension("subjectKeyIdentifier", "hash", false))
ca_cert.add_extension(ef.create_extension("authorityKeyIdentifier", "keyid:always", false))

File.open("/tmp/ca.crt", "w+") do |f|
  f.write ca_cert.to_pem
end


# ... or if you've already generated the CA, open it
ca_keypair = OpenSSL::PKey::RSA.new(File.read("/tmp/ca.pem"), ca_passphrase)
ca_cert = OpenSSL::X509::Certificate.new(File.read("/tmp/ca.crt"))

# Signing a certificate with a CA is very similar to the steps above, since
# the only difference between a CA and a signed certificate is that the latter
# is, well, signed.
our_cert_keypair = OpenSSL::PKey::RSA.new(2048)

# Signing requests are what you deliver to a CA for signing. Usually, the CA
# and the requester isn't in the same process like in this demo. The signing
# request contains the public key and the metadata you want to have for your
# certificate.
our_cert_req = OpenSSL::X509::Request.new
our_cert_req.subject = OpenSSL::X509::Name.new([
    ["C", "NO"],
    ["ST", "Oslo"],
    ["L", "Oslo"],
    ["O", "August Lilleaas"],
    ["CN", "*.augustl.com"]
  ])
our_cert_req.public_key = our_cert_keypair.public_key
our_cert_req.sign our_cert_keypair, OpenSSL::Digest::SHA1.new


# The CN (Common Name) is what browsers use to validate which domain names the
# certificate is valid for. If you aren't going to use the certificate for web
# servers, the contents of the CN field is of no technical significance. It's
# just metadata.

# At this point you typically save the our_cert_req.to_pem to a file, and send
# it to the CA. Since we're both the issuer and the requester, we'll do it inline
# right away for convenience, instead of via files.

our_cert = OpenSSL::X509::Certificate.new
our_cert.subject = our_cert_req.subject
our_cert.issuer = ca_cert.subject
our_cert.not_before = Time.now
our_cert.not_after = Time.now + 100000000 # 3 or so years.
our_cert.serial = 123 # Should be an unique number, the CA probably has a database.
our_cert.public_key = our_cert_req.public_key
our_cert.sign ca_keypair, OpenSSL::Digest::SHA1.new

# You now have a certificate signed by another certificate, in other words you
# created your own certificate authority. Congrats! Use our_cert.to_pem and write
# it to a file in order to ship it to the certificate requester.

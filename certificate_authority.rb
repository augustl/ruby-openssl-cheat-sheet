# This is not for the faint of heart.
#
# TODO: Add a ton of explanation here.

require "openssl"

# Generate your CA first. A CA is not special, it's just a private key and
# a certificate like any other. The only difference is that the certificate
# is used to sign other certificates.

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

File.open("/tmp/ca.crt", "w+") do |f|
  f.write ca_cert.to_pem
end

# Your CA is now ready to go. You can sign other certificates with it.

# Let's create a certificate and sign it with out CA. Since a certificate
# can be boiled down to "a public key with metadata and expiration date",
# we need a keypair for our new cert (just like we did for the CA cert above).
our_cert_keypair = OpenSSL::PKey::RSA.new(2048)

# The signing request is what you typically ship to the certificate authority.
# This file contains the public key of your keypair, and lets the CA issue a
# cert to you without ever sending them your private key, and without you ever
# seeing their private key.
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

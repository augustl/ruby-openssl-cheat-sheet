# When you buy SSL certs from a CA, you can either memorize the impossible
# to memorize OpenSSL CLI, or use the logical and sound Ruby API.

# At the heart of a SSL cert is your own keypair. Generate it.
our_cert_keypair = OpenSSL::PKey::RSA.new(2048)

# We ship off a certificate request to the CA.
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

# Send this file to the CA! There's probably a textarea in a form where
# they want you to paste in the certificate request - this is it.
File.open("/tmp/req.txt", "w+") do |f|
  f.write ca_cert.to_pem
end

# And we're done! You'll get the certificate itself from the CA, obviously.

# Also store the keypair to disk. Your SSL enabled server needs both the private
# key and the certificate.
File.open("/tmp/key.pem", "w+") do |f|
  f.write our_cert_keypair.to_pem
end



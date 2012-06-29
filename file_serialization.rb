# Many of the keys you can generate with ruby are serializable to disk. This is
# useful for writing ruby scripts that creates plain OpenSSL (and GnuTLS, and ..)
# files that anyone can use.

require "openssl"

keypair = OpenSSL::PKey::RSA.new(2048)
pub_key = keypair.public_key

# PEM format
File.open("/tmp/out.pem", "w+") do |f|
  f.write keypair.to_pem
end

File.open("/tmp/out-pub.pem", "w+") do |f|
  f.write pub_key.to_pem
end

# DER format
File.open("/tmp/out.der", "w+") do |f|
  f.write keypair.to_der
end

File.open("/tmp/out-pub.der", "w+") do |f|
  f.write pub_key.to_der
end

# Reading the files is easy. Ruby will automatically detect the format.

# The keypair for the private key contains both. The public key is just a
# function of the private key.
got = OpenSSL::PKey::RSA.new(File.read("/tmp/out.der"))
p got.private? # => true
p got.public?  # => true

# The public key does not contain the private key, obviously.
got = OpenSSL::PKey::RSA.new(File.read("/tmp/out-pub.der"))
p got.private? # => false
p got.public?  # => true


# You probably want to encrypt the private key on disk, though. That's easy too.
p File.read("/tmp/out.pem")
# => -----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQ  ......etc

pk_passphrase = "secretsauce"
File.open("/tmp/out.pem", "w+") do |f|
  # You can list available chiphers.
  #p OpenSSL::Cipher.ciphers
  f.write keypair.to_pem(OpenSSL::Cipher.new("AES-128-CBC"), pk_passphrase)
end
p File.read("/tmp/out.pem")
# => "-----BEGIN RSA PRIVATE KEY-----\nProc-Type: 4,ENCRYPTED\nDEK-Info: AES-128-CBC,C323774  ......etc

begin
  got = OpenSSL::PKey::RSA.new(File.read("/tmp/out.pem"), "wrong passphrase")
rescue OpenSSL::PKey::RSAError
  # Yup, that won't work
end

got = OpenSSL::PKey::RSA.new(File.read("/tmp/out.pem"), pk_passphrase)
p got.private?
# => true
p got.to_pem
# => -----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQ  ......etc

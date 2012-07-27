# Asymmetric digital signatures is a great way to verify integrity and
# authenticity of data. Create a keypair, send the public key to your
# receivers, and use this method to create a digital signature. By combining
# the data and the public key, you can verify that the signature was created
# by the owner of the private key.

require "openssl"

data = "A small brown fox."

########################
# Sign a piece of data #
########################

digest = OpenSSL::Digest::SHA256.new
# To list available digests:
#p OpenSSL::Digest.constants

keypair = OpenSSL::PKey::DSA.new(2048)
# Or
keypair = OpenSSL::PKey::RSA.new(2048)

signature = keypair.sign(digest, data)

#########################
#  Verify the signature #
#########################

# The public key is just a function of the private key. You can lose the
# public key. As long as you have the private key, you can just generate
# the public key again, it doesn't change.
pub_key = keypair.public_key

# You can read the file from disk, you probably didn't have the keypair available post creation like we have in this example.
#pub_key = OpenSSL::PKey::RSA.new(File.read("/tmp/ruby-ssl-cheatsheet/our.pub"))

p pub_key.verify(digest, signature, data)
# => true
p pub_key.verify(digest, signature, data + "altered")
# => false
p pub_key.verify(digest, "altered" + signature, data)
# => false

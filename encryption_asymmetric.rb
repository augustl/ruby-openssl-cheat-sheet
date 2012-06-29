# Asymmetric crypto is awesome.
#
# TODO: Add lengthy explanation of how it can be used to verify identity
# and all sorts of awesomeness.

require "openssl"

data = "Some private data is here."

keypair = OpenSSL::PKey::RSA.new(2048)
pub_key = keypair.public_key

# You can encrypt with the private key and decrypt with the public key
encrypted = keypair.private_encrypt(data)
p encrypted
# => ...some unreadable binary stuff...

decrypted = pub_key.public_decrypt(encrypted)
p decrypted
# => "Some private data is here."

# And vice versa
encrypted = pub_key.public_encrypt(data)
p encrypted
# => ...some unreadable binary stuff...

decrypted = keypair.private_decrypt(encrypted)
p decrypted
# => "Some private data is here."

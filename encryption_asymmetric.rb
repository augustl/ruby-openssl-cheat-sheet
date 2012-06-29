# Asymmetric crypto is awesome.
#
# TODO: Add lengthy explanation of how it can be used to verify identity
# and all sorts of awesomeness.

require "openssl"

data = "Some private data is here."

keypair = OpenSSL::PKey::RSA.new(2048)
pub_key = keypair.public_key

# You can encrypt with the private key and decrypt with the public key.
encrypted = keypair.private_encrypt(data)
p encrypted
# => ...some unreadable binary stuff...

decrypted = pub_key.public_decrypt(encrypted)
p decrypted
# => "Some private data is here."

# If you send someone your public key, and you send them data that is encrypted
# with your private key, the receiver can use this to verify that the message came
# from you, since only the owner of the private key is able to encrypt data
# so that it is decryptable with the public key.
#
# This is a common way of signing data for identity. For example, an SSL certificate
# contains a signature, which is a hash of the contents of the certificate (up until
# the bundled signature), encrypted with the private key of the issuer. Others can
# then perform the same hashing of the contents of the certificate, and decrypt
# the certificates bundled signature with the public key of the issuer. If the
# signatures match, we're cryptographically certain that the certificate was
# unaltered (or the hash would change) and that it was not issued by a man in
# the middle (or the signature would be different).

# You can also do encryption the other way - encrypt with the public key and
# decrypt with the private key.
encrypted = pub_key.public_encrypt(data)
p encrypted
# => ...some unreadable binary stuff...

decrypted = keypair.private_decrypt(encrypted)
p decrypted
# => "Some private data is here."

# This method is useful for transmitting data securely. Data that is encrypted
# with the public key can only be decrypted with the private key. The public
# key can not be used to decrypt. This has no practical drawbacks for the
# party that performs the encryption, since that party also have access to
# the original data. But when the encrypted data is in transport, nobody else
# can decrypt the data but the owner of the private key.

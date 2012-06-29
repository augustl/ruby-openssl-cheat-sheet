# Symmetric crypto lets you scramble some data with one shared key. It is faster
# than asymmetric crypto, but has the downside that you can only share the data
# with trusted parties, so the key has to be pre-shared somehow, unlike async
# crypto.

require "openssl"

secret = "fd5d148867091d7595c388ac0dc50bb465052b764c4db8b4b4c3448b52ee0b33df16975830acca82"
data = "This is some data"

# You can list available chiphers.
#p OpenSSL::Cipher.ciphers

# The chiphers take the format name-keylength-mode
cipher = OpenSSL::Cipher.new("AES-128-CBC")

# An alternative way of creating the object would be
cipher = OpenSSL::Cipher::AES.new(128, :CBC)

# The API is very imperative, as it binds pretty directly to the underlying C
# libraries. This call sets the object in encryption mode.
cipher.encrypt

cipher.key = secret
encrypted = cipher.update(data) + cipher.final
p encrypted
# => ...some unreadable binary stuff...

# Time to decrypt it. We need to create a new object.
decipher = OpenSSL::Cipher::AES.new(128, :CBC)
decipher.decrypt
decipher.key = secret

decrypted = decipher.update(encrypted) + decipher.final
p decrypted
# => "This is some data"

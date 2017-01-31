# crystal-sha3
A SHA-3 implementation written in Crystal.

Supports:
- The FIPS 202 SHA-3 standard (`Digest::SHA3`)
- Keccak[3] (`Digest::Keccak3`)

The main difference between the two is the value of the first byte of padding set after the input in the buffer.
For SHA-3, this byte is `6u8`. For Keccak[3] it is `1u8`.

## Usage
```
require "digest/sha3"
```

**SHA-3**
```
# Defaults to SHA3-512
Digest::SHA3.hexdigest("abc123")
# => 3274f8455be84b8c7d79f9bd93e6c8520d13f6bd2855f3bb9c006ca9f3cce25d4b924d0370f8af4e27a350fd2baeef58bc37e0f4e4a403fe64c98017fa012757

digest = Digest::SHA3.new(256)
digest.update("abc123")
digest.hexdigest
# => f58fa3df820114f56e1544354379820cff464c9c41cb3ca0ad0b0843c9bb67ee
```

**Keccak3**
```
# Defaults to a hash size of 512
Digest::Keccak3.hexdigest("abc123")
# => 17c4bf22aaa8fcd7ff070fd3435619b5666dc3eac901872c73f091d9f3753cd871161269f14741e3b263c616e9f4bb4314abcbb271b2796d14eb89434a0afd03

digest = Digest::Keccak3.new(256)
digest.update("abc123")
digest.hexdigest
# => 719accc61a9cc126830e5906f9d672d06eab6f8597287095a2c55a8b775e7016
```

## Running specs
Currently KAT specs are generated and not stored in this repository.

```
make spec
crystal spec
```

ExtremelyLongMsg KAT data for Keccak is included in the repo but is not tested.

LongMsg KAT data for SHA3 has not been located but should be added if a suitable source is found.

## Benchmarks
Coming soon

## Other comments
As of the 0.1.0 release, the SHA3 code has not been optimised. There are likely several performance improvements that can be made.

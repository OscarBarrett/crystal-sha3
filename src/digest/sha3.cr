require "base64"

# Defines the padding to use based on the SHA-3 function domain.
private class Domain
  SHA3  = 6u8
  SHAKE = 1u8 # Keccak[3]
end

class Digest::SHA3
  def self.digest(string : String) : Bytes
    digest(string.to_slice)
  end

  def self.digest(slice : Bytes) : Bytes
    context = self.new
    context.update(slice)
    context.result
  end

  def self.hexdigest(string_or_slice : String | Bytes) : String
    digest(string_or_slice).to_slice.hexstring
  end

  def self.base64digest(string_or_slice : String | Bytes) : String
    Base64.strict_encode(digest(string_or_slice).to_slice)
  end

  def hexdigest : String
    result.to_slice.hexstring
  end

  HASH_SIZES = Int32.static_array(224, 256, 384, 512)

  DOMAIN = Domain::SHA3

  RNDC = UInt64.static_array(
    0x0000000000000001, 0x0000000000008082, 0x800000000000808a,
    0x8000000080008000, 0x000000000000808b, 0x0000000080000001,
    0x8000000080008081, 0x8000000000008009, 0x000000000000008a,
    0x0000000000000088, 0x0000000080008009, 0x000000008000000a,
    0x000000008000808b, 0x800000000000008b, 0x8000000000008089,
    0x8000000000008003, 0x8000000000008002, 0x8000000000000080,
    0x000000000000800a, 0x800000008000000a, 0x8000000080008081,
    0x8000000000008080, 0x0000000080000001, 0x8000000080008008
  )

  # No longer used due to Rho Pi being unrolled.
  # ROTC = Int32.static_array(
  #   1,  3,  6,  10, 15, 21, 28, 36, 45, 55, 2,  14,
  #   27, 41, 56, 8,  25, 43, 62, 18, 39, 61, 20, 44
  # )
  #
  # PILN = Int32.static_array(
  #   10, 7,  11, 17, 18, 3, 5,  16, 8,  21, 24, 4,
  #   15, 23, 19, 13, 12, 2, 20, 14, 22, 9,  6,  1
  # )

  def initialize(hash_size = 512)
    unless HASH_SIZES.includes? hash_size
      raise "Invalid hash size: #{hash_size}. Must be one of #{HASH_SIZES.join(',')}"
    end

    @input = uninitialized Bytes
    @buffer = Pointer(UInt32).malloc(25_u32)
    @size = UInt32.new(hash_size / 8)
  end

  # Ruby-style method names
  def update(s : String)
    update(s.to_slice)
  end

  def update(s : Bytes)
    @input = s
    self
  end

  # Crystal-style method name
  def input(s)
    update(s)
  end

  def reset
    @buffer.clear
    self
  end

  def result
    state = Pointer(UInt64).malloc(25_u64)
    width = 200 - @size * 2

    padding_size  = width - @input.size % width
    buffer_size   = @input.size + padding_size

    # Initialize and fill buffer with the input string
    buffer = Pointer(UInt8).malloc(buffer_size)
    buffer.copy_from(@input.pointer(0), @input.size)

    # Set the first padded bit
    # Regarding the assignment: https://github.com/crystal-lang/crystal/issues/3241
    buffer[@input.size] = {% begin %}{{@type.id}}::DOMAIN{% end %}

    # Zero-pad the buffer up to the message width
    (buffer + @input.size + 1).clear(padding_size)

    # Set the final bit of padding to 0x80
    buffer[buffer_size-1] = (buffer[buffer_size-1] | 0x80)

    state_size = width / 8
    (0..buffer_size-1).step(width) do |j|
      state_size.times do |i|
        state[i] ^= (buffer + j).as(UInt64*)[i]
      end

      keccak(state)
    end

    # Return the result
    state.as(UInt8*).to_slice(@size)
  end

  private def keccak(state : Pointer(UInt64))
    lanes = Pointer(UInt64).malloc(5_u64)

    24.times do |round|
      # Theta
      lanes[0] = state[0] ^ state[5] ^ state[10] ^ state[15] ^ state[20]
      lanes[1] = state[1] ^ state[6] ^ state[11] ^ state[16] ^ state[21]
      lanes[2] = state[2] ^ state[7] ^ state[12] ^ state[17] ^ state[22]
      lanes[3] = state[3] ^ state[8] ^ state[13] ^ state[18] ^ state[23]
      lanes[4] = state[4] ^ state[9] ^ state[14] ^ state[19] ^ state[24]

      (0..4).each do |i|
        t = lanes[(i + 4) % 5] ^ rotl64(lanes[(i + 1) % 5], 1)
        state[i     ] ^= t
        state[i +  5] ^= t
        state[i + 10] ^= t
        state[i + 15] ^= t
        state[i + 20] ^= t
      end

      # Rho Pi
      # The below loop, unrolled. > 40% faster
      # t = state[1]
      # 24.times do |i|
      #   lanes[0] = state[PILN[i]]
      #   state[PILN[i]] = rotl64(t, ROTC[i])
      #   t = lanes[0]
      # end

      s1 = state[1]
      state[1]  = rotl64(state[6], 44)
      state[6]  = rotl64(state[9], 20)
      state[9]  = rotl64(state[22], 61)
      state[22] = rotl64(state[14], 39)
      state[14] = rotl64(state[20], 18)
      state[20] = rotl64(state[2], 62)
      state[2]  = rotl64(state[12], 43)
      state[12] = rotl64(state[13], 25)
      state[13] = rotl64(state[19], 8)
      state[19] = rotl64(state[23], 56)
      state[23] = rotl64(state[15], 41)
      state[15] = rotl64(state[4], 27)
      state[4]  = rotl64(state[24], 14)
      state[24] = rotl64(state[21], 2)
      state[21] = rotl64(state[8], 55)
      state[8]  = rotl64(state[16], 45)
      state[16] = rotl64(state[5], 36)
      state[5]  = rotl64(state[3], 28)
      state[3]  = rotl64(state[18], 21)
      state[18] = rotl64(state[17], 15)
      state[17] = rotl64(state[11], 10)
      state[11] = rotl64(state[7], 6)
      state[7]  = rotl64(state[10], 3)
      state[10] = rotl64(s1, 1)

      # Chi
      (0..24).step(5) do |j|
        lanes.copy_from(state + j, 5)
        state[j    ] ^= (~lanes[1]) & lanes[2]
        state[j + 1] ^= (~lanes[2]) & lanes[3]
        state[j + 2] ^= (~lanes[3]) & lanes[4]
        state[j + 3] ^= (~lanes[4]) & lanes[0]
        state[j + 4] ^= (~lanes[0]) & lanes[1]
      end

      # Iota
      state[0] ^= RNDC[round]
    end
  end

  private def rotl64(x : UInt64, y : Int32)
    (x << y | x >> 64 - y)
  end
end

class Digest::Keccak3 < Digest::SHA3
  DOMAIN = Domain::SHAKE
end

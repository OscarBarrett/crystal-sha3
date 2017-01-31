# Hexadecimal conversion helper functions
# Used primarily to convert the KAT Msg field from a Hexadecimal string to Bytes
private def hex_to_u8(value)
  if '0' <= value <= '9'
    (value - '0').to_u8
  elsif 'A' <= value <= 'F'
    10_u8 + (value - 'A')
  elsif 'a' <= value <= 'f'
    10_u8 + (value - 'a')
  else
    raise "not a hex digit: #{value}"
  end
end

def to_hex_bytes(string)
  Bytes.new(string.bytesize / 2) do |i|
    hex_to_u8(string.to_slice[i*2].chr)*16 + hex_to_u8(string.to_slice[i*2 + 1].chr)
  end
end

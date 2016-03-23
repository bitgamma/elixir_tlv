# TLV

Provides functions to decode, encode and work with ASN.1 BER-TLV structures. It supports tags encoded on multiple
bytes, length encoded on multiple bytes, indefinite length and both primitive and constructed TLVs.

## Installation
Add tlv to your list of dependencies in `mix.exs`:

    def deps do
      [{:tlv, "~> 0.0.1"}]
    end

## Examples

### Decoding TLVs
      # Primitive TLV + data after its end
      iex> TLV.decode(<<0x80, 0x02, 0xCA, 0xFE, 0xAA, 0xBB>>)
      {%TLV{indefinite_length: false, tag: 0x80, value: <<0xCA, 0xFE>>}, <<0xAA, 0xBB>>}

      # Constructed TLV
      iex> TLV.decode(<<0xE0, 0x03, 0x80, 0x01, 0xAA>>)
      {%TLV{indefinite_length: false, tag: 0xE0, value:
        [%TLV{indefinite_length: false, tag: 0x80, value: <<0xAA>>}]
      }, ""}

      # Malformed TLV
      iex> TLV.decode(<<0x80, 0x02, 0x00>>)
      :no_tlv

### Encoding TLVs
      # Primitive TLV
      iex> TLV.encode(%TLV{tag: 0x80, value: <<0xAA, 0xBB>>})
      <<0x80, 0x02, 0xAA, 0xBB>>

      # Constructed TLV
      iex> TLV.encode(%TLV{tag: 0xE0, value: [%TLV{tag: 0x80, value: <<0xAA>>}]})
      <<0xE0, 0x03, 0x80, 0x01, 0xAA>>

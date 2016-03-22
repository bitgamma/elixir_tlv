defmodule TLV do
  @moduledoc """
  Provides functions to decode, encode and work with ASN.1 BER-TLV structures. It supports tags encoded on multiple
  bytes, length encoded on multiple bytes, indefinite length and both primitive and constructed TLVs.

  """

  defstruct [:tag, :value, indefinite_length: false]

  @doc """
  Decodes (recursively) the first binary encoded TLV in the given binary and returns a tuple with the parsed TLV
  structure and the remaining data as a binary in the form `{parsed_tlv, remaining_data}`

  ## Examples
      #Primitive TLV + data after its end
      iex> TLV.decode(<<0x80, 0x02, 0xCA, 0xFE, 0xAA, 0xBB>>)
      {%TLV{indefinite_length: false, tag: 0x80, value: <<0xCA, 0xFE>>}, <<0xAA, 0xBB>>}

      #Constructed TLV
      iex> TLV.decode(<<0xE0, 0x03, 0x80, 0x01, 0xAA>>)
      {%TLV{indefinite_length: false, tag: 0xE0, value:
        [%TLV{indefinite_length: false, tag: 0x80, value: <<0xAA>>}]
      }, ""}
  """
  defdelegate decode(tlv), to: TLVDecoder

  @doc """
  TODO
  """
  defdelegate encode(tlv), to: TLVEncoder
end

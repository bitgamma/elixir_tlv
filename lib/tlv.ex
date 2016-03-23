defmodule TLV do
  @moduledoc """
  Provides functions to decode, encode and work with ASN.1 BER-TLV structures. It supports tags encoded on multiple
  bytes, length encoded on multiple bytes, indefinite length and both primitive and constructed TLVs.
  """

  @typedoc """
  Represents a BER-TLV structure. The `tag` is represented as a number with header-bits not separated from the tag.
  This is to accomodate common usages of the encoding. Primitive TLVs have a binary `value`, while constructed have
  a list of TLVs. The `indefinite_length` field is set by the decoder to reflect the original byte representation and
  also serves as instruction to the encoder on how to encode the length.
  """
  @type t :: %TLV{tag: integer, value: binary | [TLV.t], indefinite_length: boolean}
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
  @spec decode(binary) :: {TLV.t, binary}
  defdelegate decode(tlv), to: TLVDecoder

  @doc """
  TODO
  """
  @spec decode(TLV.t) :: binary
  defdelegate encode(tlv), to: TLVEncoder
end

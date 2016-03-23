defmodule TLVEncoderTest do
  use ExUnit.Case

  @data_pool Enum.reduce(1..65536, <<>>, fn(x, acc) -> acc <> <<x::unsigned-big-integer-size(8)>> end)
  @data_4 binary_part(@data_pool, 0, 4)
  @data_7f binary_part(@data_pool, 0, 127)
  @data_80 binary_part(@data_pool, 0, 128)
  @data_ff binary_part(@data_pool, 0, 255)
  @data_100 binary_part(@data_pool, 0, 256)
  @data_10000 @data_pool

  test "encodes a TLV with primitive tag on 1 byte and various lengths" do
    assert TLV.encode(%TLV{tag: 0x80, value: @data_4}) == <<0x80, 0x04>> <> @data_4
    assert TLV.encode(%TLV{tag: 0x80, value: @data_7f}) == <<0x80, 0x7F>> <> @data_7f
    assert TLV.encode(%TLV{tag: 0x80, value: <<>>}) == <<0x80, 0x00>>
    assert TLV.encode(%TLV{tag: 0x80, value: @data_80}) == <<0x80, 0x81, 0x80>> <> @data_80
    assert TLV.encode(%TLV{tag: 0x80, value: @data_ff}) == <<0x80, 0x81, 0xFF>> <> @data_ff
    assert TLV.encode(%TLV{tag: 0x80, value: @data_100}) == <<0x80, 0x82, 0x01, 0x00>> <> @data_100
    assert TLV.encode(%TLV{tag: 0x80, value: @data_10000}) == <<0x80, 0x83, 0x01, 0x00, 0x00>> <> @data_10000
  end

  test "encodes a TLV with constructed tag and definite length" do
    assert TLV.encode(%TLV{tag: 0xE0, value:
      [%TLV{tag: 0x80, value: @data_4},
      %TLV{tag: 0x81, value: @data_4}]
    }) == <<0xE0, 0x0C, 0x80, 0x04>> <> @data_4 <> <<0x81, 0x04>> <> @data_4

    assert TLV.encode(%TLV{tag: 0xE0, value:
      [%TLV{tag: 0xA0, value: [%TLV{tag: 0x80, value: @data_4}]}]
    }) == <<0xE0, 0x08, 0xA0, 0x06, 0x80, 0x04>> <> @data_4
  end

  test "encodes a TLV with constructed tag and indefinite length" do
    assert TLV.encode(%TLV{tag: 0xE0, indefinite_length: true, value:
      [%TLV{tag: 0x80, value: @data_4},
      %TLV{tag: 0x81, value: @data_4}]
    }) == <<0xE0, 0x80, 0x80, 0x04>> <> @data_4 <> <<0x81, 0x04>> <> @data_4 <> <<0x00, 0x00>>
  end

  test "ignores indefinite length field when encoding primitive tags" do
    assert TLV.encode(%TLV{tag: 0x80, value: @data_4, indefinite_length: true}) == <<0x80, 0x04>> <> @data_4
  end
end

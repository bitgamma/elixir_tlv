defmodule TLVDecoderTest do
  use ExUnit.Case

  @data_pool Enum.reduce(1..65536, <<>>, fn(x, acc) -> acc <> <<x::unsigned-big-integer-size(8)>> end)
  @data_4 binary_part(@data_pool, 0, 4)
  @data_7f binary_part(@data_pool, 0, 127)
  @data_80 binary_part(@data_pool, 0, 128)
  @data_ff binary_part(@data_pool, 0, 255)
  @data_100 binary_part(@data_pool, 0, 256)
  @data_10000 @data_pool

  test "decodes a TLV with primitive tag on 1 byte and length on 1 byte" do
    assert {%TLV{indefinite_length: false, tag: 0x80, value: @data_4}, ""} == TLV.decode(<<0x80, 0x04>> <> @data_4)
    assert {%TLV{indefinite_length: false, tag: 0x80, value: ""}, ""} == TLV.decode(<<0x80, 0x00>>)
    assert {%TLV{indefinite_length: false, tag: 0x80, value: @data_7f}, ""} == TLV.decode(<<0x80, 0x7F>> <> @data_7f)
  end

  test "decodes a TLV with primitive tag on 1 byte and length on 2 bytes" do
    assert {%TLV{indefinite_length: false, tag: 0xC4, value: @data_80}, ""} == TLV.decode(<<0xC4, 0x81, 0x80>> <> @data_80)
    assert {%TLV{indefinite_length: false, tag: 0xC4, value: @data_ff}, ""} == TLV.decode(<<0xC4, 0x81, 0xFF>> <> @data_ff)

  end

  test "decodes a TLV with primitive tag on 1 byte and length on 3 and 4 bytes with spurious data at end" do
    assert {%TLV{indefinite_length: false, tag: 0x80, value: @data_100}, "rest"} == TLV.decode(<<0x80, 0x82, 0x01, 0x00>> <> @data_100 <> "rest")
    assert {%TLV{indefinite_length: false, tag: 0x80, value: @data_10000}, "rest"} == TLV.decode(<<0x80, 0x83, 0x01, 0x00, 0x00>> <> @data_10000 <> "rest")
  end

  test "decodes a TLV with primitive tag on primitive tag on 2, 3 and 4 bytes and length on 2 bytes" do
    assert {%TLV{indefinite_length: false, tag: 0x9F70, value: @data_4}, ""} == TLV.decode(<<0x9F, 0x70, 0x81, 0x04>> <> @data_4)
    assert {%TLV{indefinite_length: false, tag: 0x9F8522, value: @data_4}, ""} == TLV.decode(<<0x9F, 0x85, 0x22, 0x81, 0x04>> <> @data_4)
    assert {%TLV{indefinite_length: false, tag: 0x1F85A201, value: @data_4}, ""} == TLV.decode(<<0x1F, 0x85, 0xA2, 0x01, 0x81, 0x04>> <> @data_4)
  end

  test "returns :no_tlv on invalid tlvs" do
    assert :no_tlv == TLV.decode(<<>>)
    assert :no_tlv == TLV.decode(<<0x80>>)
    assert :no_tlv == TLV.decode(<<0x9F>>)
    assert :no_tlv == TLV.decode(<<0x80, 0x01>>)
    assert :no_tlv == TLV.decode(<<0x80, 0x81>>)
    assert :no_tlv == TLV.decode(<<0x80, 0x80>>)
  end

  test "decodes a TLV with constructed tag on 1 byte and length on 1 byte." do
    assert {%TLV{indefinite_length: false, tag: 0xE1, value:
      [%TLV{indefinite_length: false, tag: 0x80, value: <<0xAA, 0xBB>>},
      %TLV{indefinite_length: false, tag: 0x82, value: <<0xBB, 0xCC>>}],
    }, ""} == TLV.decode(<<0xE1, 0x08, 0x80, 0x02, 0xAA, 0xBB, 0x82, 0x02, 0xBB, 0xCC>>)

    assert {%TLV{indefinite_length: false, tag: 0xE1, value: []}, ""} == TLV.decode(<<0xE1, 0x00>>)

    assert {%TLV{indefinite_length: false, tag: 0xE1, value:
      [%TLV{indefinite_length: false, tag: 0xA0, value: [%TLV{indefinite_length: false, tag: 0x82, value: <<0xCA, 0xFE>>}]},
       %TLV{indefinite_length: false, tag: 0x00, value: ""},
       %TLV{indefinite_length: false, tag: 0x83, value: <<0xBB, 0xCC>>}]
    }, ""} == TLV.decode(<<0xE1, 0x0C, 0xA0, 0x04, 0x82, 0x02, 0xCA, 0xFE, 0x00, 0x00, 0x83, 0x02, 0xBB, 0xCC>>)
  end

  test "decodes a TLV with constructed tag on 1 byte and indefinite length." do
    assert {%TLV{indefinite_length: true, tag: 0xE1, value:
      [%TLV{indefinite_length: false, tag: 0x81, value: <<0x00, 0x00>>},
      %TLV{indefinite_length: false, tag: 0x82, value: <<0xBB, 0xCC>>}],
    }, <<0xAA, 0xFF>>} == TLV.decode(<<0xE1, 0x80, 0x81, 0x02, 0x00, 0x00, 0x82, 0x02, 0xBB, 0xCC, 0x00, 0x00, 0xAA, 0xFF>>)

    assert {%TLV{indefinite_length: true, tag: 0xE1, value:
      [%TLV{indefinite_length: false, tag: 0xA0, value: [%TLV{indefinite_length: false, tag: 0x81, value: <<0x03>>}]}],
    }, ""} == TLV.decode(<<0xE1, 0x80, 0xA0, 0x03, 0x81, 0x01, 0x03, 0x00, 0x00>>)
  end
end

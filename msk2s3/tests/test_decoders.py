import base64

from msk2s3.decoders import JsonDecoder, Base64Decoder


def test_json_decoder():
    json_str = '{"key": "value"}'
    result = JsonDecoder(json_str)
    assert result == {"key": "value"}


def test_base64_decoder():
    original_data = "Hello, World!"
    base64_str = base64.b64encode(original_data.encode())
    result = Base64Decoder(base64_str).decode()
    assert result == original_data

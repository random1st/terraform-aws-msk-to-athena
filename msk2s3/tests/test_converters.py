import base64
import json
from unittest import mock
import pytest
from msk2s3.converters import ParquetConverter
from msk2s3.kafka_event import KafkaRecord

sample_records = [
    KafkaRecord(
        topic="my-topic",
        partition=0,
        offset=15,
        timestamp=1609459200000,  # 2021-01-01 00:00:00 UTC
        timestampType="CREATE_TIME",
        key="abcDEFghiJKLmnoPQRstuVWXyz1234==",
        value=base64.b64encode(json.dumps({"field": "value"}).encode()).decode(),
        headers=[]
    )
]

@pytest.fixture
def parquet_converter():
    mock_uploader = mock.Mock()
    converter = ParquetConverter(uploader=mock_uploader)
    return converter, mock_uploader

def test_upload_records(parquet_converter):
    converter, mock_uploader = parquet_converter
    converter.upload_records(sample_records)

    assert mock_uploader.called, "Method uploader was not called"

    upload_call_args_list = mock_uploader.call_args_list
    assert len(upload_call_args_list) > 0, "Method uploader was not called"

    for call_args in upload_call_args_list:
        file_path, s3_key = call_args[0]
        assert s3_key.startswith("my-topic/year=2021/month=01/day=01/")
        assert s3_key.endswith(".parquet")

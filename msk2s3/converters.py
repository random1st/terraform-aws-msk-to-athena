from __future__ import annotations

import tempfile
import uuid
from datetime import datetime, timezone
from typing import TYPE_CHECKING, Any

import pandas as pd

from msk2s3.decoders import Base64Decoder, JsonDecoder

if TYPE_CHECKING:
    from msk2s3.kafka_event import KafkaRecord
    from msk2s3.uploaders import Uploader


class ParquetConverter:
    decoders = [Base64Decoder, JsonDecoder]

    def __init__(self, uploader: Uploader) -> None:
        self.uploader = uploader

    def upload_records(self, records: list[KafkaRecord]) -> None:
        grouped_records = self._group_records_by_date(records)
        for partition_key, record_batch in grouped_records.items():
            self._save_partition_to_s3(partition_key, record_batch)

    def _group_records_by_date(self, records: list[KafkaRecord]) -> dict[str, list[dict]]:
        topic = records[0].topic
        grouped_records: dict[str, list[dict]] = {}
        for record in records:
            partition_key = self._generate_partition_key(topic, record.timestamp)
            decoded_value = self._decode_value(record.value)
            if partition_key not in grouped_records:
                grouped_records[partition_key] = []
            grouped_records[partition_key].append(decoded_value)
        return grouped_records

    @staticmethod
    def _generate_partition_key(topic: str, timestamp: int) -> str:
        dt = datetime.fromtimestamp(timestamp / 1000, tz=timezone.utc)
        return f"{topic}/year={dt.year}/month={dt.month:02d}/day={dt.day:02d}"

    def _decode_value(self, value: str) -> Any:
        for decoder in self.decoders:
            value = decoder(value)
        return value

    def _save_partition_to_s3(self, partition_key: str, records: list[dict]) -> None:
        file_key = f"{partition_key}/{uuid.uuid4()}.parquet"
        self._write_to_parquet(records, file_key)

    def _write_to_parquet(self, records: list[dict], file_key: str) -> None:
        temp_df = pd.DataFrame(records)
        with tempfile.NamedTemporaryFile(suffix=".parquet", dir="/tmp", delete=True) as temp_file:
            temp_df.to_parquet(temp_file.name, index=False)
            self.uploader(temp_file.name, file_key)

import os

from msk2s3.converters import ParquetConverter
from msk2s3.kafka_event import KafkaEvent
from msk2s3.uploaders import S3Uploader

bucket = os.getenv("BUCKET_NAME", "")


def lambda_handler(event: dict, context: dict) -> None:
    kafka_event_object = KafkaEvent(**event)
    converter = ParquetConverter(S3Uploader(bucket))

    for records in kafka_event_object.records.values():
        converter.upload_records(records)

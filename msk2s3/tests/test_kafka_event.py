from msk2s3 import KafkaEvent

json_data = {
    "eventSource": "aws:kafka",
    "eventSourceArn": "arn:aws:kafka:us-east-1:123456789012:cluster/vpc-2priv-2pub/751d2973-a626-431c-9d4e-d7975eb44dd7-2",
    "bootstrapServers": "b-2.demo-cluster-1.a1bcde.c1.kafka.us-east-1.amazonaws.com:9092,b-1.demo-cluster-1.a1bcde.c1.kafka.us-east-1.amazonaws.com:9092",
    "records": {
        "mytopic-0": [
            {
                "topic": "mytopic",
                "partition": 0,
                "offset": 15,
                "timestamp": 1545084650987,
                "timestampType": "CREATE_TIME",
                "key": "abcDEFghiJKLmnoPQRstuVWXyz1234==",
                "value": "SGVsbG8sIHRoaXMgaXMgYSB0ZXN0Lg==",
                "headers": [
                    {
                        "headerKey": [
                            104, 101, 97, 100, 101, 114, 86, 97, 108, 117, 101
                        ]
                    }
                ]
            }
        ]
    }
}

def test_kafka_event():
    kafka_event = KafkaEvent(**json_data)

    assert kafka_event.eventSource == "aws:kafka"
    assert kafka_event.eventSourceArn == "arn:aws:kafka:us-east-1:123456789012:cluster/vpc-2priv-2pub/751d2973-a626-431c-9d4e-d7975eb44dd7-2"
    assert kafka_event.bootstrapServers == "b-2.demo-cluster-1.a1bcde.c1.kafka.us-east-1.amazonaws.com:9092,b-1.demo-cluster-1.a1bcde.c1.kafka.us-east-1.amazonaws.com:9092"

    records = kafka_event.records["mytopic-0"]
    assert len(records) == 1
    record = records[0]

    assert record.topic == "mytopic"
    assert record.partition == 0
    assert record.offset == 15
    assert record.timestamp == 1545084650987
    assert record.timestampType == "CREATE_TIME"
    assert record.value == "SGVsbG8sIHRoaXMgaXMgYSB0ZXN0Lg=="

    assert len(record.headers) == 1
    header = record.headers[0]
    assert header.headerKey == [104, 101, 97, 100, 101, 114, 86, 97, 108, 117, 101]

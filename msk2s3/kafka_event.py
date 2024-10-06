from pydantic import BaseModel


class KafkaHeader(BaseModel):
    headerKey: list[int]  # noqa: N815


class KafkaRecord(BaseModel):
    topic: str
    partition: int
    offset: int
    timestamp: int
    timestampType: str  # noqa: N815
    value: str
    headers: list[KafkaHeader]


class KafkaEvent(BaseModel):
    eventSource: str  # noqa: N815
    eventSourceArn: str  # noqa: N815
    bootstrapServers: str  # noqa: N815
    records: dict[str, list[KafkaRecord]]

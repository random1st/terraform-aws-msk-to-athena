import boto3


class Uploader:
    def __call__(self, file_path: str, key: str) -> None:
        raise NotImplementedError


class S3Uploader(Uploader):
    def __init__(self, bucket_name: str) -> None:
        self.bucket_name = bucket_name

    def __call__(self, file_path: str, key: str) -> None:
        s3 = boto3.client("s3")
        with open(file_path, "rb") as file_obj:
            s3.upload_fileobj(file_obj, self.bucket_name, key)

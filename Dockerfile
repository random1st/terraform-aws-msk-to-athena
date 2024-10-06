FROM public.ecr.aws/lambda/python:3.12

WORKDIR ${LAMBDA_TASK_ROOT}

ENV POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_IN_PROJECT=1 \
    POETRY_VIRTUALENVS_CREATE=0 \
    POETRY_VERSION=1.8.3 \
    PATH="/root/.local/bin:$PATH"

RUN curl -sSL https://install.python-poetry.org | python3 - --version ${POETRY_VERSION}

COPY msk2s3/pyproject.toml msk2s3/poetry.lock ${LAMBDA_TASK_ROOT}/

RUN touch README.md

RUN poetry install --only main  -vvv

COPY ./msk2s3 ${LAMBDA_TASK_ROOT}/msk2s3

RUN ls -la ${LAMBDA_TASK_ROOT}

# Command to run on container start
CMD ["msk2s3.lambda_handler"]
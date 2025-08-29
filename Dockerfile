FROM python:3.13-slim

WORKDIR /app
COPY . .

RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get clean \
    && apt-get install curl dos2unix -y \
    && rm -rf /var/lib/apt/lists/*
RUN curl -sSL https://install.python-poetry.org | python3 -
ENV PATH="/root/.local/bin:$PATH"

COPY pyproject.toml poetry.lock ./
RUN poetry install --no-root

EXPOSE 5000-5001/tcp
#RUN python3 -m poetry config virtualenvs.create false && python3 -m poetry install --no-interaction --no-ansi --no-root
RUN dos2unix ./scripts/spawn-devices.sh
CMD ["./scripts/spawn-devices.sh", "2"]

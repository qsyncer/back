# Stage 1 → Builder image
FROM python:3.8.6-alpine as builder
COPY requirements/base.txt .

# install psycopg2 dependencies and generate wheels
RUN apk add --no-cache --virtual .build-deps \
    gcc  python3-dev  musl-dev  postgresql-dev &&  \
	pip install  --no-cache-dir --upgrade pip && \
	pip wheel --no-cache-dir --no-deps --wheel-dir /wheels -r base.txt && \
	apk del --no-cache .build-deps


# Stage 2 → Runtime image
FROM python:3.8.6-alpine

RUN apk add --no-cache openssl postgresql-dev

# dockerize
ENV DOCKERIZE_VERSION v0.6.1
RUN wget https://github.com/jwilder/dockerize/releases/download/$DOCKERIZE_VERSION/dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && tar -C /usr/local/bin -xzvf dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz \
    && rm dockerize-alpine-linux-amd64-$DOCKERIZE_VERSION.tar.gz

WORKDIR /usr/src/app
COPY --from=builder /wheels /wheels

# set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

RUN pip install --upgrade pip && pip install --no-cache /wheels/* && rm -rf /wheels

# copy project file as last step to use docker cache
COPY . .

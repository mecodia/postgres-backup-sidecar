ARG PYTHON_VERSION=3.7-alpine3.11

FROM python:${PYTHON_VERSION} as builder
ARG BORGMATIC_VERSION=1.5.1
ENV PYTHONUNBUFFERED 1

WORKDIR /wheels
RUN pip3 wheel borgmatic==${BORGMATIC_VERSION}

FROM python:${PYTHON_VERSION}
ARG BORGMATIC_VERSION=1.5.1

COPY --from=builder /wheels /wheels
COPY pg_backup.sh /etc/periodic/daily/pg_backup

RUN apk --no-cache add  \
    && rm -rf /var/cache/apk/* /.cache

RUN apk --no-cache add borgbackup openssh-client bash postgresql-client \
    && pip3 install -f /wheels borgmatic==${BORGMATIC_VERSION} \
    && rm -fr /var/cache/apk/* /wheels /.cache /root/.ssh \
    && chmod 755 /etc/periodic/daily/pg_backup
WORKDIR /
ENTRYPOINT ["crond", "-f", "-d", "1"]

LABEL org.label-schema.version=${BORGMATIC_VERSION}
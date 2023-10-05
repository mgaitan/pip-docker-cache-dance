FROM python:3.8.17-slim-bullseye AS base

RUN python -m venv /opt/venv

# this will produce a /root/.cache/pip directory
FROM base AS cache_dependencies
COPY requirements.txt .
RUN /opt/venv/bin/pip install -r requirements.txt


FROM base AS dependencies
COPY requirements.txt .
RUN --mount=type=bind,source=.pip_cache/.,target=/tmp/external_pip_cache \
    ls /tmp/external_pip_cache && \
    if [ -d "/tmp/external_pip_cache/http" ]; then \
        # assumme the cache have been mounted
        # the external mounted dir is read only, so copy to the actual destination.
        mkdir -p /root/.cache/pip && \
        cp -r /tmp/external_pip_cache/* /root/.cache/pip/; \
    fi && \
    /opt/venv/bin/pip install -r requirements.txt && \
    rm -r /root/.cache/pip/



# Etapa final: copiar el código y usar el virtualenv
FROM base AS final
COPY --from=dependencies /opt/venv/ /opt/venv/
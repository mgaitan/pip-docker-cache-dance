FROM ubuntu:22.04 as base

RUN apt-get update && \
    apt-get install -y python3

RUN python -m venv /opt/venv

# 2 stage: install deps using mounted cache
FROM base AS dependencies
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked \
    /opt/venv/bin/pip install -r requirements.txt

# Etapa final: copiar el código y usar el virtualenv
FROM base AS final
COPY --from=dependencies /opt/venv/ /opt/venv/

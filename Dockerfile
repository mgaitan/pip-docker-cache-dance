
FROM python:3.8.17-slim-bullseye AS base
WORKDIR /app
COPY requirements.txt .
# 
RUN pip install --no-cache-dir virtualenv && \
    virtualenv venv

# Segunda etapa: instalación de las dependencias
FROM base AS dependencies
RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked \
    . venv/bin/activate && pip install -r requirements.txt

# Etapa final: copiar el código y usar el virtualenv
FROM base AS final
COPY --from=dependencies /app/venv /app/venv
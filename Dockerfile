FROM amazonlinux:2023@sha256:521e488723a1ae16055067e3b78954870cf1c08c9d45421b9f8ffad82b349e1c as base

RUN \
    yum -y update-minimal \
    && yum -y install \
    # To make pnpm install work
    gcc-c++ make python3 \
    # Runtime debugging
    psmisc \
    && yum clean all \
    && rm -rf /var/cache/yum

RUN python -m venv /opt/venv

# 2 stage: install deps using mounted cache
FROM base AS dependencies
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip,sharing=locked \
    /opt/venv/bin/pip install -r requirements.txt

# Etapa final: copiar el código y usar el virtualenv
FROM base AS final
COPY --from=dependencies /opt/venv/ /opt/venv/

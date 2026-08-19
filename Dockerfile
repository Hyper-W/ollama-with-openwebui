ARG OllamaVersion=latest

FROM ollama/ollama:${OllamaVersion} AS builder

ARG OllamaModelName=gemma4
ARG OllamaModelParam=12b

ENV OLLAMA_HOST=0.0.0.0
ENV OLLAMA_KEEP_ALIVE=24h
ENV OLLAMA_NUM_GPU=28
ENV OLLAMA_CONTEXT_LENGTH=65536

RUN set -eux \
    && ollama serve >/tmp/ollama.log 2>&1 & \
    OLLAMA_PID=$! \
    && n=0 \
    && until [ "$n" -ge 30 ] || ollama ps >/dev/null 2>&1; do \
    sleep 1; \
    n=$((n + 1)); \
    done \
    && ollama pull ${OllamaModelName}:${OllamaModelParam} \
    && kill "$OLLAMA_PID" || true \
    && wait "$OLLAMA_PID" 2>/dev/null || true
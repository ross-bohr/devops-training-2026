# syntax=docker/dockerfile:1
# escape=\

# -------------------------
# Global build args (can be used in FROM)
# -------------------------
ARG DOTNET_VERSION=10.0
ARG BUILD_CONFIGURATION=Release

# -------- STAGE 1: Build --------
FROM mcr.microsoft.com/dotnet/sdk:${DOTNET_VERSION} AS build

LABEL org.opencontainers.image.title="SimpleApi (build stage)" \
      org.opencontainers.image.description="Multi-stage example using every Dockerfile instruction" \
      org.opencontainers.image.version="0.1" \
      org.opencontainers.image.maintainer="Training Example <training@soprasteria.com>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /src

# ------------------------
# Local build agrs (can be used only in the current stage)
# ------------------------
ARG BUILD_CONFIGURATION

ENV DOTNET_CLI_TELEMETRY_OPTOUT=1 \
    DOTNET_NOLOGO=1

# Copy csproj and restore first (better caching)
ADD SimpleApi.csproj ./
RUN dotnet restore

# Copy everything else and publish
ADD . ./
RUN dotnet publish -c ${BUILD_CONFIGURATION} -o /app/publish --no-restore

# -------------------------
# STAGE 2: ONBUILD base stage (for demo purposes)
# ONBUILD triggers run when this image is used as a base in a later stage.
# -------------------------
FROM mcr.microsoft.com/dotnet/aspnet:${DOTNET_VERSION} AS onbuild-base

LABEL org.opencontainers.image.title="SimpleApi (onbuild base)" \
      org.opencontainers.image.description="Runtime base with ONBUILD triggers (training only)" \
      org.opencontainers.image.maintainer="Training Example <training@soprasteria.com>"

ONBUILD LABEL onbuild.triggered="true"
ONBUILD RUN echo "ONBUILD ran at build time" > /onbuild.txt

# -------- STAGE 3: Runtime --------
FROM onbuild-base AS runtime

LABEL org.opencontainers.image.title="SimpleApi (runtime)" \
      org.opencontainers.image.source="local-training"

WORKDIR /app

ARG APP_UID=10001

ENV ASPNETCORE_ENVIRONMENT=Production

# Install curl so HEALTHCHECK can call the app.
# Create a non-root user and a logs directory (for VOLUME).
RUN apt-get update \
    && apt-get install -y --no-install-recommends curl ca-certificates \
    && rm -rf /var/lib/apt/lists/* \
    && useradd --uid ${APP_UID} --create-home --shell /usr/sbin/nologin appuser \
    && mkdir -p /app/logs \
    && chown -R appuser:appuser /app

COPY --from=build /app/publish ./

# ASP.NET listens on 8080 in containers (common convention)
#ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080

VOLUME ["/app/logs"]

USER appuser

STOPSIGNAL SIGTERM

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD curl -fsS http://localhost:8080/ || exit 1

ENTRYPOINT ["dotnet", "SimpleApi.dll"]

# CMD supplies default args to ENTRYPOINT
CMD ["--urls", "http://+:8080"]

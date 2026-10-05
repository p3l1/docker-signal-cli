# signal-cli im Container. Upstream buendelt die native libsignal nur fuer
# x86_64 Linux, Windows und macOS - auf aarch64 wird sie nachgezogen.
FROM docker.io/library/eclipse-temurin:25-jre

ARG SIGNAL_CLI_VERSION=0.14.8
ARG TARGETARCH

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends curl zip; \
    rm -rf /var/lib/apt/lists/*; \
    curl -fsSL "https://github.com/AsamK/signal-cli/releases/download/v${SIGNAL_CLI_VERSION}/signal-cli-${SIGNAL_CLI_VERSION}.tar.gz" \
      | tar xz -C /opt; \
    ln -s "/opt/signal-cli-${SIGNAL_CLI_VERSION}/bin/signal-cli" /usr/local/bin/signal-cli; \
    if [ "${TARGETARCH}" = "arm64" ]; then \
      cd "/opt/signal-cli-${SIGNAL_CLI_VERSION}/lib"; \
      # Die libsignal-Version steht im Jar-Namen; ein Versionssprung von
      # signal-cli beruehrt damit keine zweite Stelle.
      v="$(ls libsignal-client-*.jar | sed 's/^libsignal-client-\(.*\)\.jar$/\1/')"; \
      curl -fsSL "https://github.com/exquo/signal-libs-build/releases/download/libsignal_v${v}/libsignal_jni.so-v${v}-aarch64-unknown-linux-gnu.tar.gz" \
        | tar xz -C /tmp; \
      zip -qj "libsignal-client-${v}.jar" /tmp/libsignal_jni.so; \
      rm /tmp/libsignal_jni.so; \
      zip -sf "libsignal-client-${v}.jar" | grep -q libsignal_jni.so; \
    fi

# Dieselbe UID wie der hermes-Nutzer, damit sich beide Container ein
# ReadWriteOnce-Volume teilen koennen.
RUN useradd --system --uid 10000 --create-home --home-dir /var/lib/signal-cli signal-cli
USER 10000

ENTRYPOINT ["signal-cli"]

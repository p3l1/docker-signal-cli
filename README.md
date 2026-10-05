# docker-signal-cli

[signal-cli](https://github.com/AsamK/signal-cli) als Container-Image für
**arm64 und amd64**, gedacht als Sidecar neben Diensten, die mit einem
signal-cli-Daemon sprechen.

## Warum es dieses Image gibt

signal-cli braucht die native Bibliothek `libsignal_jni.so`. Upstream legt sie
laut eigenem README nur für „x86_64 Linux (with recent enough glibc), Windows
and MacOS" bei — auf aarch64 stirbt jeder Aufruf mit `UnsatisfiedLinkError`.
Dieses Image zieht für arm64 das passende Artefakt aus
[exquo/signal-libs-build](https://github.com/exquo/signal-libs-build) nach und
legt es in die `libsignal-client`-Jar. Die benötigte Version liest der Bau aus
dem Jar-Namen, damit ein Versionssprung von signal-cli keine zweite Stelle
berührt.

Fertige arm64-Images gibt es auf Docker Hub nur als veraltete oder
undurchsichtige Einzelstücke. Das hier ist nachvollziehbar gebaut.

## Tags

`ghcr.io/p3l1/signal-cli`

| Tag | Inhalt |
|---|---|
| `0.14.8` | die jeweilige signal-cli-Fassung, wird bei jedem Lauf neu gebaut |
| `0.14.8-20261006` | derselbe Bau, aber unveränderlich — zum Festnageln |
| `latest` | der letzte Lauf |

Der Workflow läuft **montags**, ermittelt das neueste signal-cli-Release selbst
und baut beide Architekturen. Dependabot hält Basis-Image und Actions aktuell.

## Benutzung

Der Entrypoint ist `signal-cli`, es laufen also die gewohnten Unterbefehle.
Der Prozess läuft als UID 10000.

```bash
# Als verknüpftes Gerät anmelden - zeigt einen QR-Code
docker run --rm -it -v signal:/data ghcr.io/p3l1/signal-cli \
  --config /data link -n HermesAgent

# Daemon im HTTP-Modus
docker run -d -v signal:/data ghcr.io/p3l1/signal-cli \
  --config /data --account +49... daemon --http 127.0.0.1:8080
```

Der Zustand unter `--config` enthält die vollständigen Zugangsdaten des
verknüpften Geräts — wie ein Passwort behandeln.

## Selbst bauen

```bash
docker build --platform linux/arm64 \
  --build-arg SIGNAL_CLI_VERSION=0.14.8 \
  -t ghcr.io/p3l1/signal-cli:0.14.8 .
```

## Lizenz

Das Dockerfile steht unter der MIT-Lizenz. signal-cli selbst ist GPLv3, die
nachgezogene libsignal AGPLv3 — beide Projekte behalten ihre Lizenzen.

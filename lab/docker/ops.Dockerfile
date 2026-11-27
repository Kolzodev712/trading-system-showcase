# syntax=docker/dockerfile:1
FROM alpine:3.20
RUN apk add --no-cache curl jq bash ca-certificates python3 \

    && arch="$(apk --print-arch)" \
    && case "$arch" in \
         x86_64) target=linux_x86_64 ;; \
         aarch64) target=linux_arm64 ;; \
         *) echo "unsupported arch $arch" >&2; exit 1 ;; \
       esac \
    && wget -q -O /tmp/grpcurl.tgz \
         "https://github.com/fullstorydev/grpcurl/releases/download/v1.9.3/grpcurl_1.9.3_${target}.tar.gz" \
    && tar -C /usr/local/bin -xzf /tmp/grpcurl.tgz grpcurl \
    && rm /tmp/grpcurl.tgz
ENTRYPOINT ["sleep", "infinity"]

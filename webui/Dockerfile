FROM free5gc/base:latest AS builder
FROM alpine:3.8

LABEL description="Free5GC open source 5G Core Network" \
    version="Stage 3"

ENV F5GC_MODULE webui
ARG DEBUG_TOOLS

# Install debug tools ~ 100MB (if DEBUG_TOOLS is set to true)
RUN if [ "$DEBUG_TOOLS" = "true" ] ; then apk add -U vim strace net-tools curl netcat-openbsd ; fi

# Set working dir
WORKDIR /free5gc
RUN mkdir -p config/ webconsole/public

# Copy executable, frontend static files and default configuration
COPY --from=builder /free5gc/${F5GC_MODULE} ./webconsole
COPY --from=builder /free5gc/public ./webconsole/public

# Such a shame - under k8s cannot access config as volume on local path (it thinks they are directories, not files - bizzare)
# so need to copy them at build time
COPY ./free5GC.conf /free5gc/config
COPY ./webuicfg.conf /free5gc/config

# Move to the executable location
WORKDIR /free5gc/webconsole

# Config files volume
VOLUME [ "/free5gc/config" ]

# WebUI uses the port 5000
EXPOSE 5000

FROM grafana/promtail as base
CMD ["--config.file=/etc/promtail/config.yaml"]

FROM base as vpc
COPY ./config-vpc.yaml /etc/promtail/config.yaml

FROM base as public
COPY ./config.yaml /etc/promtail/config.yaml
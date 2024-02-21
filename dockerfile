FROM grafana/promtail
CMD ["--config.file=/etc/promtail/config.yaml"]
COPY /etc/promtail/config.yaml

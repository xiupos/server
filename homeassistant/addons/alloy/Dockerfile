FROM grafana/alloy:v1.22.0
COPY config.alloy /etc/alloy/config.alloy
CMD ["run", "--server.http.listen-addr=127.0.0.1:12345", "--storage.path=/data/alloy", "/etc/alloy/config.alloy"]

`sudo useradd --no-create-home --shell /bin/false node_exporter`

`cd ~`
`wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz`

`tar xvf node_exporter-1.9.1.linux-amd64.tar.gz`

`sudo mv node_exporter-0.18.1.linux-amd64 /opt/node_exporter`
`sudo chown -R node_exporter:node_exporter /opt/node_exporter`

File.open('/etc/systemd/system/node_exporter.service', 'a+') do |file|
file << "[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/opt/node_exporter/node_exporter --collector.systemd

[Install]
WantedBy=multi-user.target"
end

`sudo systemctl daemon-reload`
`sudo systemctl start node_exporter && sudo journalctl -f --unit node_exporter`

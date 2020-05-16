#!/bin/bash

# Add minio user
useradd -s /sbin/nologin -d /opt/minio minio

# Set up Minio Directory & install binary
mkdir -p /opt/minio/bin
wget https://dl.minio.io/server/minio/release/linux-amd64/minio -O /opt/minio/bin/minio
chmod +x /opt/minio/bin/minio

# Creat Minio config file
echo "MINIO_VOLUMES=/mnt/tank/minio" > /opt/minio/minio.conf

# Ensure all files are owned by minio in /opt/minio, and in data path
chown -R minio:minio /opt/minio
chown -R minio:minio /mnt/tank/minio

# Create minio systemd file
cat <<EOF > /etc/systemd/system/minio.service
[Unit]
Description=Minio
Documentation=https://docs.minio.io
Wants=network-online.target
After=network-online.target
AssertFileIsExecutable=/opt/minio/bin/minio
 
[Service]
WorkingDirectory=/opt/minio
 
User=minio
Group=minio
 
PermissionsStartOnly=true
 
EnvironmentFile=-/opt/minio/minio.conf
ExecStartPre=/bin/bash -c "[ -n \"${MINIO_VOLUMES}\" ] || echo \"Variable MINIO_VOLUMES not set in /etc/default/minio\""
 
ExecStart=/opt/minio/bin/minio server $MINIO_OPTS $MINIO_VOLUMES
 
StandardOutput=journal
StandardError=inherit
 
# Specifies the maximum file descriptor number that can be opened by this process
LimitNOFILE=65536
 
# Disable timeout logic and wait until process is stopped
TimeoutStopSec=0
 
# SIGTERM signal is used to stop Minio
KillSignal=SIGTERM
 
SendSIGKILL=no
 
SuccessExitStatus=0
 
[Install]
WantedBy=multi-user.target
EOF

systemctl enable --now minio.service
firewall-cmd --permanent --add-port=9000/tcp
firewall-cmd --reload
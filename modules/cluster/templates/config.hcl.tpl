# Run Vault in HA mode. Even if there's only one Vault node, it doesn't hurt to
# have this set.
api_addr = "${api_addr}"
cluster_addr = "https://LOCAL_IP:8201"

# Set debugging level
log_level = "${vault_log_level}"

# Enable the UI
ui = ${vault_ui_enabled == "true" ? true : false}

# Enable plugin directory
plugin_directory = "/etc/vault.d/plugins"

# Enable auto-unsealing with Google Cloud KMS
seal "gcpckms" {
  project    = "${kms_project}"
  region     = "${kms_location}"
  key_ring   = "${kms_keyring}"
  crypto_key = "${kms_crypto_key}"
}

# Enable HA backend storage with GCS
storage "raft" {
  path    = "/opt/vault/data"
  retry_join {
    auto_join = "provider=gce tag_value=ncabatoff-vault"
    auto_join_scheme = "http"
    auto_join_port = 8200
  }
}

# Create local non-TLS listener
listener "tcp" {
  address     = "127.0.0.1:${vault_port}"
  tls_disable = 1
}

# Create an mTLS listener on the load balancer
listener "tcp" {
  address            = "${lb_ip}:${vault_port}"
  tls_disable = 1
}

# Create an mTLS listener locally. Client's shouldn't talk to Vault directly,
# but not all clients are well-behaved. This is also needed so the nodes can
# communicate with each other.
listener "tcp" {
  address            = "LOCAL_IP:${vault_port}"
  tls_disable = 1
}

# Send data to statsd (Stackdriver monitoring)
telemetry {
  statsd_address   = "127.0.0.1:8125"
  disable_hostname = true
}

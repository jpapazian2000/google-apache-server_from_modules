output "vm_ip" {
    value = tolist(module.gcp-infra.vm_ip)
}

output "artifact_revocation_date" {
  value = data.hcp_packer_artifact.apache_gce.revoke_at
}

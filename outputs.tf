# ============================================================
# outputs.tf — EpicBook Capstone
#
# Single VM serves both frontend and backend.
# Both outputs point to the same IP so the App pipeline
# artifact format stays consistent.
# ============================================================

output "epicbook_public_ip" {
  description = "Public IP of the EpicBook VM"
  value       = azurerm_public_ip.pip.ip_address
}

# These two outputs use the same IP intentionally
# Nginx (port 80) and Node.js (port 8080) run on the same VM
output "frontend_public_ip" {
  description = "Public IP for frontend access (Nginx on port 80)"
  value       = azurerm_public_ip.pip.ip_address
}

output "backend_public_ip" {
  description = "Public IP for backend access (Node.js on port 8080)"
  value       = azurerm_public_ip.pip.ip_address
}

output "cloudrun_url" {
  value = google_cloud_run_service.app.status[0].url
}

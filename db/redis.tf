resource "aiven_redis" "redis1" {
  project                 = var.aiven_redis_project
  cloud_name              = "do-sgp"
  plan                    = "free-1"
  service_name            = "yltech-free-redis1"
  maintenance_window_dow  = "monday"
  maintenance_window_time = "10:00:00"

  redis_user_config {
    redis_maxmemory_policy = "allkeys-random"

    public_access {
      redis = true
    }
  }
}

output "redis_uri" {
  value = aiven_redis.redis1.service_uri
}

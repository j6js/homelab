terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.1.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

data "docker_registry_image" "frigate" {
  name = "ghcr.io/blakeblackshear/frigate:stable"
}

resource "docker_image" "frigate" {
  name          = data.docker_registry_image.frigate.name
  pull_triggers = [data.docker_registry_image.frigate.sha256_digest]
}

resource "docker_container" "frigate" {
  name  = "frigate"
  image = docker_image.frigate.name

  ports {
    internal = 8971
    external = 8971
  }

  ports {
    internal = 8555
    external = 8555
    protocol = "udp"
  }

  ports {
    internal = 8555
    external = 8555
    protocol = "tcp"
  }

  devices {
    host_path      = "/dev/dri"
    container_path = "/dev/dri"  
   }

  volumes {
    host_path      = "/opt/frigate/config"
    container_path = "/config"
  }

  volumes {
    host_path      = "/opt/frigate/clips"
    container_path = "/clips"
  }

  volumes {
    host_path      = "/opt/frigate/recordings"
    container_path = "/recordings"
  }
}


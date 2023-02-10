variable "datacenters" {
    type = list(string)
    default = [ "dc1" ]
}

variable "local_port" {
    type = "string"
    default = 8081
}

job "octopi" {
    datacenters = var.datacenters
    
    type = "service"
    
    group "svc" {
        count = 1
        restart {
            attempts = 5
            delay = "15s"
        }
        network {
            port "http" {
                static       = var.local_port
                to           = 80
            }
        }
        task "app" {
            driver = "docker"
            config {        
                image = "octoprint/octoprint"
                ports = [ "http" ]
                devices = [
                    {
                        host_path = "/dev/ttyACM0"
                        container_path = "/dev/ttyACM0"
                    },
                    {
                        host_path = "/dev/video0"
                        container_path = "/dev/video0"
                    }
                ]
            }
            env = {
                "ENABLE_MJPG_STREAMER"  = true
            }
        }
    }
}
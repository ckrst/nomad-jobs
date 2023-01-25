variable "server_ip" {
    type = "string"
}

variable "datacenters" {
    type = list(string)
    default = [ "dc1" ]
}

job "pihole" {
    datacenters = var.datacenters
    
    type = "service"
    
    group "svc" {
        count = 1
        restart {
            attempts = 5
            delay = "15s"
        }
        network {
            port "dns" {
                static       = 53
                to           = 53
            }
            port "http" {
                static       = 8080
                to           = 80
            }
        }
        task "app" {
            driver = "docker"
            config {        
                image = "pihole/pihole:latest"
                mount {
                    type = "bind"
                    target = "/etc/pihole"
                    source = "local"
                    readonly = false
                    bind_options {
                        propagation = "rshared"
                    }
                }
                # mount {
                #     type = "bind"
                #     target = "/etc/dnsmasq.d"
                #     source = "data"
                #     readonly = false
                #     bind_options {
                #         propagation = "rshared"
                #     }
                # }
                ports = [ "dns", "http" ]
                dns_servers = [
                    "127.0.0.1",
                    "1.1.1.1",
                ]
            }
            env = {
                "TZ"           = "America/Sao_Paulo"
                "WEBPASSWORD"  = "${var.pihole_password}"
                "DNS1"         = "1.1.1.1"
                "DNS2"         = "no"
                "INTERFACE"    = "eth0"
                "VIRTUAL_HOST" = "nomad-server"
                "ServerIP"     = var.server_ip
            }
        }
    }
}
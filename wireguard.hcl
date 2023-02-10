variable "datacenters" {
    type = list(string)
    default = [ "dc1" ]
}

variable "local_port" {
    type = "string"
    default = 51820
}

variable "server_url" {
    type = "string"
    default = "127.0.0.1"
}

job "wireguard" {
    datacenters =  var.datacenters
    
    type = "service"
    
    group "svc" {
        count = 1

        restart {
            attempts = 5
            delay = "15s"
        }
        network {
            port "svcport" {
                static       = var.local_port
                to           = 51820
            }
        }
        task "wireguard" {
            driver = "docker"
            config {        
                image = "linuxserver/wireguard"

                ports = [ "svcport" ]

                # cap_add = ["net_admin", "sys_module"]

                sysctl = {
                    "net.ipv4.conf.all.src_valid_mark" = "1"
                }
                
            }

            volume_mount {
                volume = "wireguard_config"
                destination = "/config"
                read_only = false
            }

            env = {
                "TZ" = "America/Sao_Paulo"
                "PUID" = 1000
                "PGID" = 1000
                "SERVERURL" = var.server_url
                "SERVERPORT" = var.local_port
                "PEERS" = 1 #optional
                "PEERDNS" = "auto" #optional
                "INTERNAL_SUBNET" = "10.13.13.0" #optional
                "ALLOWEDIPS" = "0.0.0.0/0" #optional
            }
        }

        volume "wireguard_config" {
            type      = "host"
            read_only = false
            source    = "wireguard_config"
        }
    }
}
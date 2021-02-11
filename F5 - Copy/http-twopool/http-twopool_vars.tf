variable "bigip_host" {
    default="192.168.1.1"
}
variable "bigip_username" {
    default="admin"
    sensitive = true
}

variable "bigip_password" {
    description = "Please enter bigip password"
    sensitive = true
    default=""
}

variable "vs_name" {
    description = "Please enter Virtual Server Name"
}
variable "vs_ip" {
    description = "Please enter Virtual Server IP (VIP) in the format 192.168.2.1"
}
variable "node1IpAndPort" {
    description = "Please enter Pool Member 1 IP and Port in the format 192.168.3.1:80"
}
variable "node2IpAndPort" {
    description = "Please enter Pool Member 2 IP and Port in the format 192.168.3.2:80"
}
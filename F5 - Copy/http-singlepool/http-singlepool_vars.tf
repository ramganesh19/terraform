variable "bigip_host" {
    default="192.168.1.1"
}
variable "bigip_username" {
    default="admin"
}
variable "bigip_password" {
    description = "Please enter bigip password"
}
variable "vs_name" {
    description = "Please enter Virtual Server Name"
}
variable "vs_ip" {
    description = "Please enter Virtual Server IP (VIP) in the format 192.168.2.1"
}
variable "nodeIpAndPort" {
    description = "Please enter Pool Member IP and Port in the format 192.168.3.1:80"
}
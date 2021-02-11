variable "bigip_host" {
    default="192.168.1.1"
}
variable "bigip_username" {
    default="admin"
    sensitive = true
}
variable "vs_ip" {
    description = "Please enter Virtual Server IP (VIP) in the format 192.168.2.1"
}
variable "vs_name" {
    description = "Please enter Virtual Server Name"
}

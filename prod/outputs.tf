# output "prod_k8s_cp1_global_ip" {
#   value = yandex_compute_instance.prod_k8s_cp1[*].network_interface.0.nat_ip_address
# }
# output "prod_k8s_node1_global_ip" {
#   value = yandex_compute_instance.prod_k8s_node1[*].network_interface.0.nat_ip_address
# }
# output "prod_k8s_node2_global_ip" {
#   value = yandex_compute_instance.prod_k8s_node2[*].network_interface.0.nat_ip_address
# }
# output "prod_k8s_node3_global_ip" {
#   value = yandex_compute_instance.prod_k8s_node3[*].network_interface.0.nat_ip_address
# }
output "prod_jenkins_global_ip" {
  value = yandex_compute_instance.prod_jenkins[*].network_interface.0.nat_ip_address
}
output "nat_instance_global_ip" {
  value = yandex_compute_instance.nat-instance[*].network_interface.0.nat_ip_address
}
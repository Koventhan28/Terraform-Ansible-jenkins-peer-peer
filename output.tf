#Output for getting the public ip address of the Jenkins nodes
output "Jenkins-Main-Node-Public-IP" {
  value = aws_instance.jenkins-master.public_ip
}

output "Jenkins-Worker-Public-IPs" {
  value = {
    for instance in aws_instance.jenkins-worker-oregon :
    instance.id => instance.public_ip
  }
}

# Add LB DNS name to Outputs
output "LB_DNS_NAME" {
  value = aws_lb.application-lb.dns_name
  
}

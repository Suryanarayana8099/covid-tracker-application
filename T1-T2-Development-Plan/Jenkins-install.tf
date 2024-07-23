resource "aws_iam_instance_profile" "existing_instance_profile" {
  name = "existing_instance_profile"
  role = "rfiser_SSMforEC2"
}

resource "aws_instance" "jenkins" {
  ami                  = "ami-08012c0a9ee8e21c4" # Replace with the latest Ubuntu 20.04 LTS AMI for your region
  #instance_type        = "t3.large"
  instance_type = var.instance_type_list[1]  # For List
  iam_instance_profile = aws_iam_instance_profile.existing_instance_profile.name
  security_groups      = [aws_security_group.jenkins_sg-test.name]
  key_name             = aws_key_pair.surya_keypair.key_name

  tags = {
    Name = "Jenkins Server"
  }

  connection {
    user        = var.instance_user
    private_key = file("${var.private_key_path}")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y openjdk-17-jdk",
      "sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key",
      "echo \"deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/\" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null",
      "sudo apt-get update",
      "sudo apt-get install -y jenkins",
      "sudo service jenkins start",
      "sudo apt update",
      "curl \"https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip\" -o \"awscliv2.zip\"",
      "sudo apt update",
      "sudo apt install -y unzip",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "curl -LO https://dl.k8s.io/release/v1.28.0/bin/linux/amd64/kubectl",
      "chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
      "curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.18.9/2020-11-02/bin/linux/amd64/aws-iam-authenticator",
      "chmod +x ./aws-iam-authenticator",
      "sudo mv ./aws-iam-authenticator /usr/local/bin/",
      "sudo apt-get install -y docker.io",
      "sudo systemctl start docker",
      "sudo systemctl enable docker",
      "sudo usermod -aG docker ubuntu",
      "echo 'jenkins ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/jenkins",
      "sudo aws configure set aws_access_key_id ${var.aws_access_key}",
      "sudo aws configure set aws_secret_access_key ${var.aws_secret_key}",
      "sudo rm -r /var/lib/jenkins/plugins /var/lib/jenkins/jobs /var/lib/jenkins/credentials.xml",
      "sudo aws s3 cp s3://eks-backupfile/T1-jenkins-backup.tar.gz /var/lib",
      "sudo systemctl stop jenkins",
      "sudo tar -xvzf /var/lib/T1-jenkins-backup.tar.gz -C /var/lib",
      "sudo chown -R jenkins:jenkins /var/lib/jenkins/",
      "sudo systemctl start jenkins",
      "sudo aws eks update-kubeconfig --region us-west-1 --name eks_cluster",
    ]
  }
    depends_on = [aws_eks_cluster.eks_cluster]

}


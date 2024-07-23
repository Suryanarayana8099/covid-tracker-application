# Create EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "eks_cluster"
  role_arn = "arn:aws:iam::881329308612:role/ddjoricEKSClusterRole"
 
  vpc_config {
    subnet_ids = concat(aws_subnet.eks_subnet_a[*].id, aws_subnet.eks_subnet_b[*].id)
  }
}
 
# Create Node Group for EKS Cluster
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "my-eks-node-group"
  node_role_arn = "arn:aws:iam::881329308612:role/ddjoricEKSWorkerNodeRole"
  #node_role_arn   = "arn:aws:iam::881329308612:role/ddjoricEKSWorkerNodeRole"
  #node_role_arn = "arn:aws:iam::aws:policy/aws-service-role/AWSServiceRoleForAmazonEKSNodegroup"
  subnet_ids      = concat(aws_subnet.eks_subnet_a[*].id, aws_subnet.eks_subnet_b[*].id)
 
  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }
  instance_types = ["t3.large"]  # Set the instance type to t3.large
 
  # Ensure node groups are created after the cluster
  depends_on = [aws_eks_cluster.eks_cluster]
}
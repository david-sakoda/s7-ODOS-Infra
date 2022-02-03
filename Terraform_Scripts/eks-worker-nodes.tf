#
# EKS Worker Nodes Resources
#  * IAM role allowing Kubernetes actions to access other AWS services
#  * EKS Node Group to launch worker nodes
#

resource "aws_iam_role" "preprod-node" {
  name = "terraform-eks-preprod-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "preprod-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.preprod-node.name
}

resource "aws_iam_role_policy_attachment" "preprod-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.preprod-node.name
}

resource "aws_iam_role_policy_attachment" "preprod-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.preprod-node.name
}

resource "aws_eks_node_group" "private-nodes" {
  cluster_name    = aws_eks_cluster.preprod-cluster.name
  node_group_name = "private-nodes"
  node_role_arn   = aws_iam_role.preprod-node.arn
  subnet_ids = [
        aws_subnet.public-us-east-1a.id,
        aws_subnet.private-us-east-1a.id,
        aws_subnet.private-us-east-1b.id
    ]
  instance_types   = ["t3.medium"]

  scaling_config {
      desired_size    = 2
      max_size        = 5
      min_size        = 0
    }

  update_config {
      max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.preprod-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.preprod-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.preprod-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

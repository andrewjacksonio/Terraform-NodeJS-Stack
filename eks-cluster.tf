#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "default-cluster" {
  name = "terraform-eks-default-cluster"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "default-cluster-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.default-cluster.name
}

resource "aws_iam_role_policy_attachment" "default-cluster-AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.default-cluster.name
}

resource "aws_security_group" "default-cluster" {
  name        = "terraform-eks-default-cluster"
  description = "Cluster communication with worker nodes"
  vpc_id      = data.aws_vpc.default.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-default"
  }
}

resource "aws_security_group_rule" "default-cluster-ingress-workstation-https" {
  cidr_blocks       = [local.workstation-external-cidr]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.default-cluster.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "default" {
  name     = var.cluster-name
  role_arn = aws_iam_role.default-cluster.arn

  vpc_config {
    security_group_ids = [aws_security_group.default-cluster.id]
    subnet_ids         = [data.aws_subnet.default-us-west-2a.id,data.aws_subnet.default-us-west-2b.id,data.aws_subnet.default-us-west-2c.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.default-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.default-cluster-AmazonEKSServicePolicy,
  ]
}

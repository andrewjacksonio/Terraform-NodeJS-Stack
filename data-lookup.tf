data "aws_iam_role" "ecsInstanceRole" {
  name = "ecsInstanceRole"
}

data "aws_iam_server_certificate" "andrewjacksonio" {
  name_prefix = "andrewjacksonio"
  latest      = true
}

data "aws_vpc" "default" {
  id = "vpc-e3d03786"
}
/*
resource "aws_subnet" "default" {
  count = 2

  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = "10.0.${count.index}.0/24"
  vpc_id            = aws_vpc.default.id

  tags = map(
    "Name", "terraform-eks-default-node",
    "kubernetes.io/cluster/${var.cluster-name}", "shared",
  )
}
*/
data "aws_subnet" "default-us-west-2a" {
  filter {
    name   = "tag:Name"
    values = ["default-us-west-2a"]
  }
}

data "aws_subnet" "default-us-west-2b" {
  filter {
    name   = "tag:Name"
    values = ["default-us-west-2b"]
  }
}

data "aws_subnet" "default-us-west-2c" {
  filter {
    name   = "tag:Name"
    values = ["default-us-west-2c"]
  }
}
/*
data "aws_internet_gateway" "default" {
  id = "igw-c3f1efa1"
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.default.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_route_table_association" "default" {
  count = 2

  subnet_id      = aws_subnet.default.*.id[count.index]
  route_table_id = aws_route_table.default.id
}
*/
resource "aws_subnet" "main" {
  vpc_id                  = var.vpc_id
  cidr_block              = var.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-${var.subnet_type}-subnet-${var.availability_zone}"
      Type = var.subnet_type
    },
    var.tags
  )
}

resource "aws_route_table" "main" {
  vpc_id = var.vpc_id

  tags = merge(
    {
      Name = "${var.project_name}-${var.environment}-${var.subnet_type}-rt"
    },
    var.tags
  )
}

resource "aws_route_table_association" "main" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.main.id
}
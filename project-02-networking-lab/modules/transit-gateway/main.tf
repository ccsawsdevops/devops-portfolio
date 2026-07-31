resource "aws_ec2_transit_gateway" "main" {
  description                     = "${var.project_name}-${var.environment}-tgw"
  auto_accept_shared_attachments  = "enable"
  default_route_table_association = "enable"
  default_route_table_propagation = "enable"

  tags = {
    Name = "${var.project_name}-${var.environment}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "main" {
  for_each = var.vpc_attachments

  subnet_ids         = each.value.subnet_ids
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = each.value.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-tgw-attach-${each.key}"
  }
}
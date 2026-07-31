resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = var.customer_ip
  type       = "ipsec.1"

  tags = {
    Name = "${var.project_name}-${var.environment}-cgw"
  }
}

resource "aws_vpn_gateway" "main" {
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.project_name}-${var.environment}-vgw"
  }
}

resource "aws_vpn_connection" "main" {
  customer_gateway_id = aws_customer_gateway.main.id
  type                = "ipsec.1"
  vpn_gateway_id      = aws_vpn_gateway.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-vpn"
  }
}
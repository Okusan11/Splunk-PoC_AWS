
  
  #--------------------------------------
  # Elasti IP Public_subnet_splunk_1d
  #--------------------------------------
  
  # https://www.terraform.io/docs/providers/aws/r/eip.html
  
  
  resource "aws_eip" "nat_splunk_1d" {
    vpc = true
    # domain ="vpc" // VPC内でEIPを使用
  }
  
  
  #--------------------------------------
  # NAT Gateway Public_subnet_splunk_1d
  #--------------------------------------
  
  # https://www.terraform.io/docs/providers/aws/r/nat_gateway.html
  
  resource "aws_nat_gateway" "nat_splunk_1d" {
    subnet_id     = "${aws_subnet.public_subnet_splunk_1d.id}" # NAT Gatewayを配置するSubnetを指定
    allocation_id = "${aws_eip.nat_splunk_1d.id}"       # 紐付けるElastic IP
  
    tags = {
      Name = "ngw-splunk-1d"
    }
  
  }
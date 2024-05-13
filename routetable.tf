  # #--------------------------------------
  # # Route Table (Public)
  # # 経路情報の格納
  # # ログ収集用のVPCのRoutetable
  # #--------------------------------------
  
  # # https://www.terraform.io/docs/providers/aws/r/route_table.html
  

  resource "aws_route_table" "public_splunk" {
    vpc_id = "${aws_vpc.miratsuku_vpc_1.id}"
  }
  
  #--------------------------------------
  # Route (Public)
  # Route Tableへ経路情報を追加
  # インターネット(0.0.0.0/0)へ接続する際はInternet Gatewayを使用するように設定する
  #--------------------------------------
  
  # https://www.terraform.io/docs/providers/aws/r/route.html
  
  resource "aws_route" "public_splunk" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id         = "${aws_route_table.public_splunk.id}"
    gateway_id             = "${aws_internet_gateway.igw_miratsuku_vpc.id}"
  }
  
  #--------------------------------------
  # Association (Public)
  # Route TableとSubnetの紐づけ
  #--------------------------------------
  
  # https://www.terraform.io/docs/providers/aws/r/route_table_association.html
  
  resource "aws_route_table_association" "public_splunk_1d" {
    subnet_id      = "${aws_subnet.public_subnet_splunk_1d.id}"
    route_table_id = "${aws_route_table.public_splunk.id}"
  }
  
  ##############################################################
  
  #--------------------------------------
  # Route Table (Private)
  #--------------------------------------
  
  # https://www.terraform.io/docs/providers/aws/r/route_table.html
  
  resource "aws_route_table" "private_splunk_1d" {
    vpc_id = "${aws_vpc.miratsuku_vpc_1.id}"
  }
  
  #--------------------------------------
  # Route (Private)
  #--------------------------------------
  
  # https://www.terraform.io/docs/providers/aws/r/route.html
  
  resource "aws_route" "private_splunk_1d" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id         = "${aws_route_table.private_splunk_1d.id}"
    nat_gateway_id         = "${aws_nat_gateway.nat_splunk_1d.id}"
  }
  
  #--------------------------------------
  # Association (Private)
  #--------------------------------------
  
  # https://www.terraform.io/docs/providers/aws/r/route_table_association.html
  
  resource "aws_route_table_association" "private_splunk_1d" {
    subnet_id      = "${aws_subnet.private_subnet_splunk_1d.id}"
    route_table_id = "${aws_route_table.private_splunk_1d.id}"
  }
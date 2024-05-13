#--------------------------------------
#Public subnet@ap-northeast-1c
#--------------------------------------

resource "aws_subnet" "public_subnet_splunk_1c" {
  vpc_id            = aws_vpc.miratsuku_vpc_1.id
  availability_zone = "ap-northeast-1c"
  cidr_block        = "10.2.3.0/24"

  tags = {
    Name = "miratsuku-public_subnet_splunk_1c"
  }

}

#--------------------------------------
#Public subnet@ap-northeast-1d
#--------------------------------------

resource "aws_subnet" "public_subnet_splunk_1d" {
  vpc_id            = aws_vpc.miratsuku_vpc_1.id
  availability_zone = "ap-northeast-1d"
  cidr_block        = "10.2.1.0/24"

  tags = {
    Name = "miratsuku-public_subnet_splunk_1d"
  }

}

#--------------------------------------
#Private subnet@ap-northeast-1d
#--------------------------------------

resource "aws_subnet" "private_subnet_splunk_1d" {
  vpc_id            = aws_vpc.miratsuku_vpc_1.id
  availability_zone = "ap-northeast-1d"
  cidr_block        = "10.2.2.0/24"

  tags = {
    Name = "miratsuku-private_subnet_splunk_1d"
  }

}

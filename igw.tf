  #--------------------------------------
  #Internet Gateway
  #--------------------------------------
    
  resource "aws_internet_gateway" "igw_miratsuku_vpc" {
    vpc_id = aws_vpc.miratsuku_vpc_1.id
  
    tags = {
      Name = "miratsuku-igw"
    }
  
  }
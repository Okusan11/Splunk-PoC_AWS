# ---------------------------
# EC2 Key pair
# ---------------------------
variable "key_name" {
  description = "keypair pisc"
  default     = "miratsuku-ssh-key-2024"
}

# 秘密鍵のアルゴリズム設定
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# クライアントPCにKey pair（秘密鍵と公開鍵）を作成
# - Windowsの場合はフォルダを"\\"で区切る（エスケープする必要がある）
# - [terraform apply] 実行後はクライアントPCの公開鍵は自動削除される
locals {
  public_key_file  = "C:\\Users\\YUKIOKUMURA\\.key_pair\\${var.key_name}.id_rsa.pub"
  private_key_file = "C:\\Users\\YUKIOKUMURA\\.key_pair\\${var.key_name}.id_rsa"
}

resource "local_file" "private_key_pem" {
  filename = local.private_key_file
  content  = tls_private_key.private_key.private_key_pem
}

# 上記で作成した公開鍵をAWSのKey pairにインポート
resource "aws_key_pair" "key_pair" {
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh
}


# Amazon Linux 2 の最新版AMIを取得
data "aws_ssm_parameter" "amzn2_latest_ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# ---------------------------
# VPC_2
# Public subnetのBastion EC2
# ---------------------------

resource "aws_instance" "bastion-ec2" {
  ami                         = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type               = "t2.micro"
  availability_zone           = "ap-northeast-1d"
  vpc_security_group_ids      = [aws_security_group.bastion_ec2_sg.id]
  subnet_id                   = aws_subnet.public_subnet_splunk_1d.id
  private_ip                  = "10.2.1.4"
  associate_public_ip_address = true
  key_name                    = aws_key_pair.key_pair.id
  #   iam_instance_profile        = "higa_profile"
  tags = {
    Name = "bastion-ec2"
  }

  //キャパシティー予約をなしに設定
  capacity_reservation_specification {
    capacity_reservation_preference = "none"
  }


  #--------------------------------------
  # EBSのルートボリューム設定
  #--------------------------------------

  root_block_device {
    // ボリュームサイズ(GiB)
    volume_size = 8
    // ボリュームタイプ
    volume_type = "gp3"
    // GP3のIOPS
    iops = 3000
    // GP3のスループット
    throughput = 125
    // EC2終了時に削除
    delete_on_termination = true

    // EBSのNameタグ
    tags = {
      Name = "splunk-gp3-ec2"
    }
  }
}

#--------------------------------------
# EBSボリュームのデフォルト暗号化を有効化する
#--------------------------------------

resource "aws_ebs_encryption_by_default" "bastion-ebs-encryption" {
  enabled = true
}


#--------------------------------------
# Security Group作成
#--------------------------------------

data "http" "ifconfig" {
  url = "http://ipv4.icanhazip.com/"
}

locals {
  current-ip   = chomp(data.http.ifconfig.response_body)
  allowed-cidr = (var.allowed-cidr == null) ? "${local.current-ip}/32" : var.allowed-cidr
}

variable "allowed-cidr" {
  default = null
}

resource "aws_security_group" "bastion_ec2_sg" {
  name        = "bastion-ec2-sg"
  description = "For EC2 Linux"
  vpc_id      = aws_vpc.miratsuku_vpc_1.id
  tags = {
    Name = "bastion-ec2-sg"
  }

  # インバウンドルール
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.allowed-cidr]
  }

  # アウトバウンドルール
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# ---------------------------
# VPC2
# Private SubnetのSplunk EC2
# ---------------------------

resource "aws_instance" "splunk-ec2" {
  ami                    = data.aws_ssm_parameter.amzn2_latest_ami.value
  instance_type          = "c5.2xlarge"
  availability_zone      = "ap-northeast-1d"
  vpc_security_group_ids = [aws_security_group.splunk_ec2_sg.id]
  subnet_id              = aws_subnet.private_subnet_splunk_1d.id
  private_ip             = "10.2.2.4"
  key_name               = aws_key_pair.key_pair.id
  #   iam_instance_profile        = "higa_profile"
  tags = {
    Name = "splunk-ec2"
  }

  //キャパシティー予約をなしに設定
  capacity_reservation_specification {
    capacity_reservation_preference = "none"
  }


  #--------------------------------------
  # EBSのルートボリューム設定
  #--------------------------------------

  root_block_device {
    // ボリュームサイズ(GiB)
    volume_size = 20
    // ボリュームタイプ
    volume_type = "gp3"
    // GP3のIOPS
    iops = 3000
    // GP3のスループット
    throughput = 125
    // EC2終了時に削除
    delete_on_termination = true

    // EBSのNameタグ
    tags = {
      Name = "splunk-gp3-ec2"
    }
  }
}

#--------------------------------------
# EBSボリュームのデフォルト暗号化を有効化する
#--------------------------------------

resource "aws_ebs_encryption_by_default" "splunk-ebs-encryption" {
  enabled = true
}


#--------------------------------------
# Security Group作成
#--------------------------------------

resource "aws_security_group" "splunk_ec2_sg" {
  name        = "splunk-ec2-sg"
  description = "For EC2 Linux"
  vpc_id      = aws_vpc.miratsuku_vpc_1.id
  tags = {
    Name = "splunk-ec2-sg"
  }
    # アウトバウンドルール
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
  # インバウンドルール
resource "aws_security_group_rule" "ingress_http_fromalb" {
    type = "ingress"
    to_port = 80
    protocol = "tcp"
    source_security_group_id = aws_security_group.alb_sg.id
    from_port = 80
    security_group_id = aws_security_group.splunk_ec2_sg.id
}

resource "aws_security_group_rule" "ingress_splunk_fromalb" {
    type = "ingress"
    to_port = 8000
    protocol = "tcp"
    source_security_group_id = aws_security_group.alb_sg.id
    from_port = 8000
    security_group_id = aws_security_group.splunk_ec2_sg.id
}

resource "aws_security_group_rule" "ingress_ssh_frombastion" {
    type = "ingress"
    to_port = 22
    protocol = "tcp"
    from_port = 22
    cidr_blocks = ["10.2.1.4/32"]
    security_group_id = aws_security_group.splunk_ec2_sg.id
}

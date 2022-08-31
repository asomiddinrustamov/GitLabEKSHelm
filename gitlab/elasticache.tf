resource "aws_elasticache_cluster" "gitlab" {
  cluster_id           = "cluster-gitlab"
  engine               = "redis"
  node_type            = "cache.m4.xlarge"
  num_cache_nodes      = 1
  parameter_group_name = "default.redis5.0"
  engine_version       = "5.0.6" #"3.2.10"
  port                 = 6379
  subnet_group_name    = aws_elasticache_subnet_group.gitlab.name
  security_group_ids   = [aws_security_group.redis.id]
}

resource "aws_elasticache_subnet_group" "gitlab" {
  name       = "gitlab-cache-subnet"
  subnet_ids = var.private_subnets
}

resource "aws_security_group" "redis" {
  name        = "ElasticacheRedisSecurityGroup"
  description = "Communication between the redis and eks worker nodegroups"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ElasticacheRedisSecurityGroup"
  }
}

resource "aws_security_group_rule" "redis_inbound" {
  description              = "Allow eks nodes to communicate with Redis"
  from_port                = 6379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.redis.id
  source_security_group_id = var.cluster_security_group_id
  to_port                  = 6379
  type                     = "ingress"
}
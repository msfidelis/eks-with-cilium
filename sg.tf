# resource "aws_security_group_rule" "nodeport" {
#     cidr_blocks = ["0.0.0.0/0"]
#     from_port   = 30000
#     to_port     = 32768
#     description = "nodeport"
#     protocol    = "tcp"

#     security_group_id = aws_eks_cluster.m
#     type = "ingress"
# }
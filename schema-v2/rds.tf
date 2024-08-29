resource "aws_db_instance" "mydb" {
  depends_on                      = [aws_cloudwatch_log_group.rds_cw_log]
  allocated_storage               = 10 # gigabytes
  backup_retention_period         = 7  # in days
  db_subnet_group_name            = "rds_subnet"
  engine                          = "postgres"
  engine_version                  = "15.5"
  identifier                      = "testkc"
  instance_class                  = "db.t3.micro"
  multi_az                        = false
  db_name                         = "testtrs"
  parameter_group_name            = "default.postgres15"
  manage_master_user_password     = true
  port                            = 5349
  publicly_accessible             = false
  storage_encrypted               = false
  storage_type                    = "gp2"
  username                        = "masteradmin"
  skip_final_snapshot             = true
  apply_immediately               = true
  deletion_protection             = false
  final_snapshot_identifier       = "final-snapshot"
#  snapshot_identifier             = "test-trs-1"
  vpc_security_group_ids          = ["sg-02bf2ffee5d8be042", ]
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
}

resource "aws_cloudwatch_log_group" "rds_cw_log" {
  name              = "/aws/rds/instance/testkc/postgresql"
  retention_in_days = 14
}

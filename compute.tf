resource "aws_instance" "web" {
    ami                                  = "ami-04505e74c0741db8d"
    associate_public_ip_address          = true
    availability_zone                    = "us-east-1a"
    disable_api_termination              = false
    ebs_optimized                        = false
    get_password_data                    = false
    hibernation                          = false
    instance_initiated_shutdown_behavior = "stop"
    instance_type                        = "t2.micro"
    ipv6_address_count                   = 0
    ipv6_addresses                       = []
    key_name                             = "test-hlb-key"
    monitoring                           = false
    secondary_private_ips                = []
    source_dest_check                    = true
    subnet_id                            = aws_subnet.okto_public_subnet_1A.id
    tags                                 = {
        "Name" = "test-tpl"
    }
    tags_all                             = {
        "Name" = "test-tpl"
    }
    tenancy                              = "default"
    vpc_security_group_ids               = [
        aws_security_group.okto_sg.id,
    ]

    capacity_reservation_specification {
        capacity_reservation_preference = "open"
    }

    enclave_options {
        enabled = false
    }

    metadata_options {
        http_endpoint               = "enabled"
        http_put_response_hop_limit = 1
        http_tokens                 = "optional"
    }

    root_block_device {
        delete_on_termination = true
        encrypted             = false
        tags                  = {}
        throughput            = 0
        volume_size           = 8
        volume_type           = "gp2"
    }

    timeouts {}
}
data "aws_acm_certificate" "okto_acm" {
  domain   = "hlb-ip.xyz"
  statuses = ["ISSUED"]
}

resource "aws_lb_target_group" "okto_backend" {
    deregistration_delay          = "300"
    load_balancing_algorithm_type = "round_robin"
    name                          = "okto-stage"
    port                          = 3000
    protocol                      = "HTTP"
    protocol_version              = "HTTP1"
    slow_start                    = 0
    tags                          = {}
    tags_all                      = {}
    target_type                   = "instance"
    vpc_id                        = aws_vpc.okto_vpc.id

    health_check {
        enabled             = true
        healthy_threshold   = 5
        interval            = 30
        matcher             = "200"
        path                = "/health"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = 5
        unhealthy_threshold = 2
    }

    stickiness {
        cookie_duration = 86400
        enabled         = false
        type            = "lb_cookie"
    }
}

resource "aws_lb_target_group_attachment" "test" {
  target_group_arn  = aws_lb_target_group.okto_backend.arn
  target_id         = aws_instance.web.id
  port              = 3000
}

resource "aws_lb" "okto_application_lb" {
    drop_invalid_header_fields = false
    enable_deletion_protection = false
    enable_http2               = true
    idle_timeout               = 60
    internal                   = false
    ip_address_type            = "ipv4"
    load_balancer_type         = "application"
    name                       = "tpl-lb"
    security_groups            = [
        aws_security_group.okto_sg.id,
    ]
    tags                       = {}
    tags_all                   = {}

    subnet_mapping {
        subnet_id = aws_subnet.okto_public_subnet_1A.id
    }
    subnet_mapping {
        subnet_id = aws_subnet.okto_public_subnet_1B.id
    }

    timeouts {}
}

resource "aws_lb_listener" "redirect_to_https" {
    load_balancer_arn = aws_lb.okto_application_lb.arn
    port              = 80
    protocol          = "HTTP"
    tags              = {}
    tags_all          = {}

    default_action {
        order = 1
        type  = "redirect"

        redirect {
            host        = "#{host}"
            path        = "/#{path}"
            port        = "443"
            protocol    = "HTTPS"
            query       = "#{query}"
            status_code = "HTTP_301"
        }
    }

    timeouts {}
}

resource "aws_lb_listener" "forward_to_target_group" {
    certificate_arn   = data.aws_acm_certificate.okto_acm.arn
    load_balancer_arn = aws_lb.okto_application_lb.arn
    port              = 443
    protocol          = "HTTPS"
    ssl_policy        = "ELBSecurityPolicy-2016-08"
    tags              = {}
    tags_all          = {}

    default_action {
        order            = 1
        target_group_arn = aws_lb_target_group.okto_backend.arn
        type             = "forward"
    }

    timeouts {}
}
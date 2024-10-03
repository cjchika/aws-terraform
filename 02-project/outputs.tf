# OPTIMIZED

output "ecs_cluster_id" {
  value = aws_ecs_cluster.mern_cluster.id
}

output "ecs_service_names" {
  value = { for svc_name, svc in aws_ecs_service.services : svc_name => svc.name }
}

output "ecs_alb_names" {
  value = { for svc_name, alb in aws_lb.alb : svc_name => alb.name }
}

output "ecs_target_group_names" {
  value = { for svc_name, tg in aws_lb_target_group.tg : svc_name => tg.name }
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_sg.id
}

# OLD CODE

# output "ecs_node_service_name" {
#   value = aws_ecs_service.backend_node_svc.name
# }

# output "ecs_react_service_name" {
#   value = aws_ecs_service.frontend_react_svc.name
# }

# output "ecs_securitry_id" {
#   value = aws_security_group.ecs_sg.id
# }

# output "ecs_node_alb_name" {
#   value = aws_lb.backend_alb.name
# }

# output "ecs_react_alb_name" {
#   value = aws_lb.frontend_alb.name
# }

# output "ecs_node_tg_name" {
#   value = aws_lb_target_group.backend_tg.name
# }

# output "ecs_react_tg_name" {
#   value = aws_lb_target_group.frontend_tg.name
# }



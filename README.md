# tfdev_environments

```mermaid
C4Deployment
title Deployment Diagram for Development Environment

Person(administrator, "Administrator", "")
Person(user, "User", "")

Deployment_Node(cloud, "Open Telekom Cloud", ""){

    Deployment_Node(vpc, "Virtual Private Network", ""){
        Deployment_Node(dmz_subnet, "DMZ public net", ""){
            Deployment_Node(bastion_secgroup, "Security Group", ""){
                Deployment_Node(bastion_region, "EU-DE", ""){
                    Deployment_Node(bastion_az, "eu-de-01", ""){
                        Component(bastion, "Bastion", "ECS", "s2.medium.2/Ubuntu")
                    }
                }
            }
            Deployment_Node(elb_secgroup, "Security Group", ""){
                Component(elb, "Elastic Load Balancer", "ELB", "2")
            }
        }

        Deployment_Node(management_subnet, "Management Zone subnet", ""){
            Deployment_Node(management_secgroup, "Security Group", ""){
                Component(ansible, "Ansible", "ECS", "2")
                Component(vault, "Vault", "ECS", "2")
            }
        }

        Deployment_Node(frontend_subnet, "Front-end private subnet", ""){
            Deployment_Node(worker_secgroup, "Security Group", ""){
                Component(worker, "Worker", "ECS", "2")
            }
        }
    }

    Rel(administrator, bastion, "TCP 22", "SSH")
    Rel(bastion, administrator, "TCP 22", "SSH, 0.0.0.0/0")
    Rel(user, elb, "TCP 443", "HTTPS")
    Rel(elb, user, "TCP 443", "HTTPS, 0.0.0.0/0")

    Rel(ansible, bastion, "TCP 22", "SSH")
    Rel(bastion, ansible, "TCP 22", "SSH, 0.0.0.0/0")

}

```

Rel(mobile, spa, "Makes API calls to", "json/HTTPS")
System_Ext(banking_system, "Mainframe Banking System", "Stores all of the core banking information about customers, accounts, transactions, etc.")
Container(mobile, "Mobile App", "Xamarin", "Provides a limited subset of the Internet Banking functionality to customers via their mobile device.")



```mermaid
flowchart LR
    user[User] <--> rp[Reverse Proxy \n Load Balancer]
    rp <-->|'/*'| ws[Web frontend server];
    rp <-->|'/api/*'| as[Application Server];
    ws <--> as
    as <--> dbs[(Database Server)];
```

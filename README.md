# sonarqube

# Sonarqube Setup

SonarQube is an open-source static testing analysis software, it is used by developers to manage source code quality and consistency.
## Prerequisites
1. Need an EC2 instance (min t2.small)
2. Install Java-17

## Install & Setup Postgres Database for SonarQube
`Source: https://www.postgresql.org/download/linux/ubuntu/`  
1. Install Postgres database   

2. Set a password and connect to database

3. Create a database user and database for sonarque 

4. Restart postgres database to take latest changes effect 

 ## SonarQube Setup

1. Download [soarnqube](https://www.sonarqube.org/downloads/) and extract it.   

2. Update sonar.properties


3. Create and start sonarqube service at the boot time 

4. Add sonar user and grant ownership to /opt/sonarqube directory 

5. Reload the demon and start sonarqube service 

 ## Notes 

 1. Make sure port 9000 is opened at security group leave
 2. start sonar service as a sonar user 
 3. user correct database credentials in the sonar.properties
 4. use instance which has atleast 2 GB of RAM

# Excecute Terraform
## initialise terraform
terraform init
## run terraform validate command
terraform validate
## run terraform plan command
terraform plan
## run terraform apply command
terraform apply
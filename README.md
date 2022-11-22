# HAPIFHIR-docker-compose

Modify .env with desired values

Run: ./install.sh
  
Go to https://\<HOSTNAME\> 

![docker-compose-hapifhir yml](https://user-images.githubusercontent.com/48926694/193571255-b8588148-feb8-4189-b48a-5ce21ba58cc6.png)

# OpenHIM-docker-compose
All the commands are assuming that the target installation folder for HAPIFHIR is `/opt/hapifhir-docker'

## Install HAPIFHIR docker containers
1. `cd /opt`
2. `git clone https://github.com/solid-lines/hapifhir-docker.git`
3. `cd /opt/hapifhir-docker`
4. You can modify the environment variables used by HAPIFHIR containers by editing the .env file
5. `./install.sh HOSTNAME`

Run: ./install.sh \<HOSTNAME\>

1. Update server
2. Add the given \<HOSTNAME\> to the configuration files
3. Build and create docker containers
4. Update Nginx configuration files
  
## Uninstall HAPIFHIR docker containers
1. `cd /opt/hapifhir-docker`
2. `./uninstall.sh`

## Modify HAPIFHIR docker containers
1. `cd /opt/hapifhir-docker`
2. Modify the environment variables used by HAPIFHIR containers by editing the .env file
3. `./restart_containers.sh`

## .env file settings
### Set up the HAPIFHIR and PostgreSQL versions
* HAPIFHIR_VERSION (default is 5.6.0)
* POSTGRES_VERSION (default is 12)
### Set up Database
* POSTGRES_DB
* POSTGRES_USER
* POSTGRES_PASSWORD



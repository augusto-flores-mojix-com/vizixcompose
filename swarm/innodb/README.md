# Innodb MySql Cl.uster Configuration

The steps to deploy a cluster with innodb are displayed  below.
## Start three `mysql` hosts
In case to use `docker-compose`

```
docker-compose up -d mysqla mysqlb mysqlc
```

## In case of use `docker-compose` to get the ipaddress run.

```sh
docker-compose network inspect NETWORK_ADDRESS
```

Instances ip addresses.

```sh
172.18.0.4      mysqla
172.18.0.2      mysqlb
172.18.0.3      mysqlc
```

## Configure the routes in `/etc/hosts` for all instances.

```sh
127.0.0.1	localhost	cctest
172.18.0.4      mysqla
172.18.0.2      mysqlb
172.18.0.3      mysqlc

```

## Download the  mysqlsh client.

* URL - `https://dev.mysql.com/downloads/shell/`

## Login to all mysql instances.

```sh
./mysqlsh root@mysqla
./mysqlsh root@mysqlb
./mysqlsh root@mysqlc
```

## Run the following command in all instances in order to setup the configuration for all instances.

```sh
dba.configureInstance()
```

## login off from all instances and then restart the msyql services
in case  of use `docker-compose`

```sh
docker-compose restart mysqla mysqlb mysqlc
```

## After that all componentes are restarted login to the first instance

```sh
./mysqlsh root@mysqla
```

## Create the cluster

```sh
dba.createCluster("newCluster")
```

## get the cluster in  a variable.

```sh
var cluster = dba.getCluster();
cluster.status();
```

## Add the remaining instances to the cluster.

```sh
cluster.addInstance("root@mysqlb:3306")
cluster.addInstance("root@mysqlc:3306")
```

## Login off from the instance `\exit` command.

## Add the following configuration to `docker-compose.yml` file. Notice that the information from the fist member is provided. 

---
mysqlroutera&#58;
  image: mysql/mysql-router&#58;8.0
  ports&#58; 
    - 6446:6446
  restart&#58; always
  hostname&#58; mysqlroutera
  container_name&#58; mysqlroutera
  #mem_reservation&#58; 512m
  environment&#58;
    - MYSQL_HOST=mysqla
    - MYSQL_PORT=3306 
    - MYSQL_USER=root
    - MYSQL_PASSWORD=control123!
    - MYSQL_INNODB_NUM_MEMBERS=3
---

## Start the component and access to logs

```sh 
docker-compose up -d mysqlrouter &&docker-compose logs -f --tail 100 mysqlrouter
```

## Notice that the following information is displayed in logs.

```sh
mysqlroutera    | 2018-06-26 21:53:15 metadata_cache INFO [7fb859924700]     mysqla:3306 / 33060 - role=HA mode=RW
mysqlroutera    | 2018-06-26 21:53:15 metadata_cache INFO [7fb859924700]     mysqlb:3306 / 33060 - role=HA mode=RO
mysqlroutera    | 2018-06-26 21:53:15 metadata_cache INFO [7fb859924700]     mysqlc:3306 / 33060 - role=HA mode=RO
```
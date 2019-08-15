# ShopCX DevOps Cookbook

### Setting up MySQL for ShopCX

ShopCX requieres multiple databases that need to be created the first time you start up a system. You can login to the `shopcx-mysql` and manually create the following tables:

```
create database information_schema CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database advancloud CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database aggregates CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database businessproducts CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database configurationdevices CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database configurationlanguages CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database labstore CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database mysql CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database performance_schema CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database printing CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database recommendation CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database riot_main CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database serialization CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database statemachine CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database supplychain CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database sys CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database tagauth CHARACTER SET utf8 COLLATE utf8_unicode_ci;
create database tagmanagement CHARACTER SET utf8 COLLATE utf8_unicode_ci;
```

### Start up Elastic Search Monitoring

Before launching the service for Elastic Search, add permissions to the persisted folder and add the following change in the host that is going to be deployed.

```
chmod -R o+w /data/shopcx-es
sysctl -w vm.max_map_count=262144
sysctl -w vm.max_map_count=262144 && echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
sysctl -p
```

### Adding plugins to RabbitMQ

TODO Add this plugins inside the container so no need for persisted files.

```
echo '[rabbitmq_management,rabbitmq_shovel,rabbitmq_shovel_management].' > /data/shopcx-rabbitmq/conf/enabled_plugins
```

### Starting up InfluxDB Container

Start InfluxDB and inside the container run `influx` and create the databases

```
bash-4.3# influx
Connected to http://localhost:8086 version 1.5.4
InfluxDB shell version: 1.5.4
> CREATE DATABASE telegraf
> CREATE DATABASE asnauto
> CREATE USER admin WITH PASSWORD 'control123!' WITH ALL PRIVILEGES
```

### DP Retroactive Event Generation API

For initialization, the mysql database has to have the agreggates.schema table with no rows and the table `shippedtags` should not exist.

### Start ShopCX

After this, you can start all the components in the stack for ShopCX. Remind that some components depend on the `internaltransformer` and this will need to be up and running before you deploy all the other components.

### Test ShopCX Endpoints

Refer to this folder to test that all endpoints are working fine: /test
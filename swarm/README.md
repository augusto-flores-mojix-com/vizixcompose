# ViZix 6 on Docker Swarm

These are the steps to use Docker swarm

## Create Docker Swarm

Using the internal private IP:

```
docker swarm init --advertise-addr IP.AD.DR.ES
```

Then adding node labels
To see the node names or IDs

```
docker node ls
```

To add labels

```
docker node update --label-add host=HOST_LABEL dt2zkp6slylfwimgx33be7gvi
```

And it is done.

## Promote all Nodes to Manager

To promote a node to Manager.

```
docker node promote ID
```

## Secrets Management

To create a secret password in a Swarm Node hit:

```
printf "<supersecret>" | docker secret create sql_password -
printf "<supersecret>" | docker secret create nosql_password -
```

You can list the secrets ID with `docker secret ls`

## Azure Microsoft SQL Server

To allow services API connect to a SQL Microsoft Azure instance  use the following environemnt variables:

```
 #trying SQLServer
      VIZIX_DB_DRIVER: com.microsoft.sqlserver.jdbc.SQLServerDriver
      VIZIX_CONNECTION_URL: jdbc:sqlserver://redriotmain.database.windows.net:1433;databaseName=riot_main
      VIZIX_DB_USER: redvizix
      VIZIX_DB_PASSWORD: sunbu**********!9
      VIZIX_DB_SCHEMA: riot_main
      VIZIX_DB_DIALECT: org.hibernate.dialect.SQLServer2012Dialect
```

# ViZiX Edge Installation


## ENV Variables

Rename the `envsample` file to `.env` and change all the values that need to be changed.

```
VIZIX_CLOUD_KAFKA_BOOTSTRAP_SERVER=<vizix-cloud-hostname>:<vizix-cloud-kafka-broker-port>
VIZIX_CLOUD_KAFKA_SERVER_IP=<vizix-cloud-ip>
VIZIX_TENANT_CODE=<tenant-code>
VIZIX_PREMISE_CODE=<premise-code>
```

Note: Make sure the variables `VIZIX_TENANT_CODE` and `VIZIX_PREMISE_CODE` point to the correct tenant and premise on which this ViZiX Edge is running.

## Kafka Broker

To startup the broker, hit:

`docker-compose -f vizix-edge.yaml up -d zookeeper kedge`

## Create ViZiX Edge Required Topics

Note: These topics should be created before bringing up `mm-c2f`, i.e. before mirroring data from the cloud.

Run 

```bash
docker-compose -f vizix-edge.yaml up -d edge-tools-on-prem 
```

## Deploy ViZiX Edge Components

Bring up the rest of the containers. 

Follow this order when starting containers:

* MirrorMaker (mm-c2f)
* Transform Bridge (transformbridge)
* Rules Processor (rulesprocessor)
* Action Processor (actionprocessor)
* Kafka Websocket Connector (connect)

Use the following command to bring up each container:

`docker-compose -f vizix-edge.yaml up -d <container-name>`


## Configure the POE and POS Websocket Endpoints

After starting the `connect` container, the POE and POS websockets endpoints need to be configured in order to enable the `connect` to actually receive events from the POE and POS devices configured on the hub.

To configure the POE devices, hit the following CURL command:

```
curl -X POST \
  http://<hub address>:7083/connectors/ \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d '{
  "name": "wsPOE",
  "config": {
    "connector.class": "com.tierconnect.riot.bridges.connectors.ws.WsSourceConnector",
    "tasks.max": 1,
    "ws.url": "ws://<hub address>:8081/readergateway/receivetags/GUARD",
    "topic": "___v1___data0___<TENANT CODE>___<PREMISE CODE>___RAWEPCISEVENT",
    "buffer.chunk.maxsize": 20,
    "buffer.timeout": 10,
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.storage.StringConverter"
  }
}
'
```

To configure the POS devices in mode POS_PAYMENT, hit the following CURL command:

```
curl -X POST \
  http://<hub address>:7083/connectors/ \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d '{
  "name": "wsPOS_PAYMENT",
  "config": {
    "connector.class": "com.tierconnect.riot.bridges.connectors.ws.WsSourceConnector",
    "tasks.max": 1,
    "ws.url": "ws://<hub address>:8081/readergateway/receivetags/POS_PAYMENT",
    "topic": "___v1___data0___<TENANT CODE>___<PREMISE CODE>___RAWEPCISEVENT",
    "buffer.chunk.maxsize": 20,
    "buffer.timeout": 10,
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.storage.StringConverter"
  }
}
'
```

To configure the POS devices in mode POS_RETURN, hit the following CURL command:

```
curl -X POST \
  http://<hub address>:7083/connectors/ \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d '{
  "name": "wsPOS_RETURN",
  "config": {
    "connector.class": "com.tierconnect.riot.bridges.connectors.ws.WsSourceConnector",
    "tasks.max": 1,
    "ws.url": "ws://<hub address>:8081/readergateway/receivetags/POS_RETURN",
    "topic": "___v1___data0___<TENANT CODE>___<PREMISE CODE>___RAWEPCISEVENT",
    "buffer.chunk.maxsize": 20,
    "buffer.timeout": 10,
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.storage.StringConverter"
  }
}
'
```

To configure the POS devices in mode POS_READ_ONLY, hit the following CURL command:

```
curl -X POST \
  http://<hub address>:7083/connectors/ \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/json' \
  -d '{
  "name": "wsPOS_READ_ONLY",
  "config": {
    "connector.class": "com.tierconnect.riot.bridges.connectors.ws.WsSourceConnector",
    "tasks.max": 1,
    "ws.url": "ws://<hub address>:8081/readergateway/receivetags/POS_READ_ONLY",
    "topic": "___v1___data0___<TENANT CODE>___<PREMISE CODE>___RAWEPCISEVENT",
    "buffer.chunk.maxsize": 20,
    "buffer.timeout": 10,
    "key.converter": "org.apache.kafka.connect.storage.StringConverter",
    "value.converter": "org.apache.kafka.connect.storage.StringConverter"
  }
}
'
```


# Single Entrypoint for Merged ViZix Platform

The following container, configuration and certificate will allow having a single entrypoint for HTTP/HTTPS, AMQP/AMQPS for the platform. 
This entrypoint is being used for the hubs across the VPN to reacht the platform and RabbitMQ brokers using a single Private IP Address.

### The container

The container is based on `haproxy` public container, adding the curl capacity to healthcheck the internaltransformer/externaltransformer endpoints. 
When the transformer is being updated or down, this proxy will start restarting every 30 seconds until it's up again. 

### The certificate

The certificate attached has been generated to support any connection for `shopcx-rabbitmq:5671`. This can be reused in any other environment, but we recommend to sign and create a new certificate everytime this is deployed in a production environment. 

### TODO

* Test retries of the HUB when a transformer is being updated/down and haproxy is constantly restarting.
* Add a brief manual to know how to create a private certificate for RabbitMQ Secure.

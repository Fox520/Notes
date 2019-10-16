# Ballerina-Notes-Client
Client for notice board application using a micro-service architectural style
## Given instructions
Distributed Systems Programming (DSP620S)
In this project, your task is to design and implement Notes, a notice board
application using a micro-service architectural style. The application should
store new notices as well as display the notices for a given day, week or
month.
The application will use one single type of service, Noter. We will deploy five
instances of the service, each with its own data store. The service instances
will communicate with an API gateway and execute the aforementioned operations.
To submit a notice, a user sends an API call to the API gateway with a
notice object. The latter comprises of the identifier of the notice, its topic,
description and date of submission of the notice. Once the API gateway
receives a call to submit a notice, it randomly identifies an instance of Noter
and directs the call to it. When a service receives a call to submit a notice,
it generates a ledger from the received notice. A ledger consists of a piece
of data (here the notice), a hash1 of the data, and the hash of the previous
ledger. After creating the ledger, the service stores it locally and then start a
gossip protocol until all five instances have received and validated2 the new
ledger. Once a service validates the ledger, it stores it locally. During the
gossip protocol, a service can only interact with a single service at a time
using an HTTP protocol.
To retrieve the notices of a day, week or month, a specific API call is placed,
where a random service is selected to answer the call.
You will design Notes and implement it using the Ballerina programming
language. You will use Graphql for your API gateway. You will also choose
and configure a storage system for each service. Note that the storage systems might differ per service.
You will deploy your application using a Kubernetes cluster, with each service running in a Docker instance.
You will use the sha − 512 algorithm
The validation entails checking the hash of the previous ledger and the signature of
the current one

##
The GraphQL server will be implemented in NodeJS, whilst the user endpoint in Angular

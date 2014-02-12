Intro Client-Server Architectures w/Barrister RPC
=====================================

## Mission

The purpose of this project is to demonstrate the utility of the Barrister RPC system in building robust, composable client-server architectures. 

## What is Barrister RPC?

Barrister is a RPC system that uses an external interface definition (IDL) file to describe the interfaces and data structures that a component implements. It is similar to tools like Protocol Buffers, Thrift, Avro, and SOAP. 

## Why Barrister RPC?

Barrister RPC is transport agnostic, and includes bindings for several languages (Ruby, Python, JavaScript, and Java - to name a few). A single interface definition can be reused across languages which allows for pluggable client and server implementations.

## Approach

This demonstration will consist of three examples:

### Example 1: Client and Server In Same Process (Ruby)

I'll start by building a terminal client that sends RPC messages to perform CRUD operations against a database fronted by a simple service. Both the terminal client and server will run in the same Ruby process, and will communicate via the Barrister client. Tests will be written against the service using the Barrister client using an intra-process transport.

### Example 2: Isolated Processes, Redis Transport (Ruby <-> Ruby)

I'll modify the application we built in Step 1 to run the client and server in separate Ruby processes, communicating through a Redis list using message-passing and blocking pop. This example demonstrates a client-server architecture amenable to deploying to Heroku, whose dynos (collections of processes) run in isolation. Most importantly - neither the terminal client, service, nor IDL code from the previous step needed to change; we've just swapped one transport for another. Our tests will need to consume a differently-configured Barrister client, but the service's behavior will remain unchanged.

### Example 3: Isolated Processes, HTTP Transport (Ruby <-> JavaScript)

In the third step, I'll swap the Ruby server out for a server implemented in JavaScript with Node.js. I'll also replace the transport mechanism (Redis) with HTTP. The IDL and Ruby client remain untouched. The tests - written in Ruby using the Barrister client - remain unchanged. This example demonstrates that an interface implementations can be swapped without impacting the consumers of the interface. This should prove especially powerful to technologists interested in incrementally porting parts of a codebase to different languages or servers.

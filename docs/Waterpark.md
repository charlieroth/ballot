# Waterpark

Project Waterpark was presented by Bryan Hunter at the GigCityElixir conference in 2023. Recording of the presentation can be found here

Team aimed at building system with no downtime, prevent data hoarding due to previous incidences of this and make a places for teams to perform experiments that are fast and cheap to get results without extinguishing capital (political or otherwise)

## Overview of Waterpark

Waterpark is a general-purpose I/O system. Data can come in, potentially be transformed and is sent to another destination (Kafka topic, third-party service, etc.). Waterpark can also produce its own signals based on input it receives. A list of all the capabilities that Waterpark has:

- Integration Engine
- Streaming System
- Distributed Database
- CDN
- FaaS (Function as a Service) Platform
- Complex Event Processor
- Queue
- Cache

The reason that all of these capabilities were built via Elixir was to prevent external dependencies like Redis or Kafka which can introduce operational complexity and possible degradation of availability.

The key capability of the Waterpark project is its ability to be a distributed, geographically fault-tolerant, RAM based, embedded database.

The team building this project believed that the industry standard of reusing code that has come before them in all possible cases is a sickness that has plagued the industry. By building the subset of features, that are already provided by other services, that are tailor fit to the use cases of Waterpark they were able to avoid unnecessary dependencies in only a couple months of development. This means the deployment and failure models are their own and enables zero downtime, not a millisecond of downtime. Of course the team did not re-invent all aspects of computing.

While the Waterpark project did implement a lot of its own system components, they did not re-invent everything. Looking at the conventional hardware/software stack:

- User
- Application
- Operating System
- Hardware

They did not re-invent the Hardware level, they chose conventional physical servers with no shared memory which are widely available to anyone that wishes to operate one.

They did not re-invent the OS level, they chose to use the BEAM Virtual Machine as their OS thereby limiting their dependency on underlying operating systems to anything that can run a BEAM VM instance which is all popular operating systems in use today (Linux, MacOS, Windows, BSD). The BEAM VM handles process management, interrupts, memory management, file system operations, networking and general I/O operations.

They did however re-invent the Application and User layers, this is Waterpark project itself.

## BEAM VM & The Actor Model

Each Actor process in the BEAM VM can be simplified to four aspects:

1. Memory - each Actor process has isolated memory, preventing a plethora of memory bugs
2. Garbage Collector - each Actor process has it’s own garbage collection, making it one of the easiest garbage collectors in software systems to date
3. Mailbox - each Actor process has it’s own mailbox, preventing data races and contention of resources through asynchronous operational isolation
4. Links & Monitors - each Actor process is linked to some supervising process and can be monitored by a supervising process, ensuring that if a process crashes the system can recover in a controlled / deterministic manner

## Healthcare & The Actor Model

A BEAM VM process, or Actor process, is a digital twin of a patient in a care center. This means an Actor process per patient rather than a Database row per patient. In typical healthcare system patients are represented as a moment-in-time snapshot of data (HL7, table rows, JSON) on disk. This means most systems read patient data, perform work based on current values, flush memory buffers and move to the next piece of data.

Waterpark models each patient as a long-running “patient actor”, at the time of the presentation millions of patient actors. Patient actors run from pre-admit to post-discharge, often running for several weeks and a minimum of 21 days. A patient actor is not limited to the latest HL7 message, it holds every message and event that lead to the current state, this could be thousands of messages.

A detailed history of patient events, otherwise known as full-visit awareness, enables real-time notifications and alerts based on days or weeks of events (e.g., transfers, drugs administered, lab results, procedures).

## Going to Production

While building the project, the COVID-19 pandemic emerged and the team was told in three weeks the system must be in production. This meant the system will never again be able to take downtime. This meant the system must have the strongest of guarantees that a software system could have.

### Continuous Availability

Continuous availability means there can be no unplanned outages and no planned outages

### No Masters

To delivery on the continuous availability requirement this meant they needed to follow the ethos of “No Masters”. There can be no single points of failure in the system.

The solution to this was to create, commonly done in distributed system, availability zones for nodes in the system to operate in. They choose to create a physical architecture of 4 data centers, geographically isolated & distributed across the United States, and each data center having two availability zones, each availability zone having 4 physical servers, totaling 32 nodes.

Every node in the system is a worker and every node is storage, all nodes are peers and there are no masters in the system. The only difference between nodes in the system is the name they are assigned, they all have the same capabilities and software components. This ensures symmetry across the whole system.

## Process Pairs

The concept of process pairs was introduced by Jim Gray while building the Tandem Computers company. Joe Erlang was a fan of this concept and designed BEAM VM process with these concepts in mind.

The problem that Tandem Computing solves in a system of processes is:

- Supervisor starts a child
- Process has no data
- Process gets some data
- Process gets some more data
- Process crashes
- Process restarts
- Process has no data

## Waterpark Process Pairs

A patient goes into a care center. A patient process is created, with ID 1001, at some node in the system, the location, in the cluster, of this patient process does not matter. This initialed created patient process is the writer process for this patient. When this writer process is spawned, a read-replica process is spawned in that same data center in a different availability zone of that same data center. Additionally, a read-replica process is spawned in each of the other data centers, the availability zone does not matter. Now there is a total of 5 processes for this patient, one writer process and 4 read-replica processes. This means there will be 5 copies of every message that is received by the Waterpark system for that patient. Before there an ack returned to the client application communicating with the system, the Waterpark system guarantees that at least 3 of the 5 processes have recorded the message. This guarantees that the writer process and two of the read-replica processes have this message, in other words at least two data centers have this message stored.

In the case of a failing writer process (node or network partition), a change in the topology is detected. The writer process is re-spawned in a different node within the same datacenter and availability zone but on a different node. To recover the state of the writer process, it chooses the nearest best read-replica process to recover from. This leads to question how do we know where the writer process and corresponding read-replica process live?

## Server HashRings

The location assignment of a process is done via the bitwalker/libring library. This is one of the only aspects of the Waterpark system that depends on an external dependency. This library is small and single-purpose making it an acceptable dependency in the Waterpark system. In short, given a patient process key, it will deterministically assign the location of this process to a location in the HashRing, unless there is a change in the topology that the HashRing represents. This implementation of HashRings uses Consistent Hashing to minimizes changes as the range of the function changes. This keeps the topological structure small, deterministic and easy to share amongst nodes.

## Topology

The topology data structure is a map whose keys are the data center names, hardcoded values, and the values of the map are HashRings representing the nodes in that data center. In the case of Waterpark this is a map of 4 keys, the 4 data centers, and each map key’s value is a HashRing data structure with 8 buckets, again totaling 32 nodes. This allows the location of a patient process do be retrieved via a function call like:

```bash
iex> Topology.get_actor_server(%{id: "1001", facility: "HOSPX"})
"TN-B-2"
```

This approach to cluster topology removed the requirement for a globally-consistent process registry. A globally-consistent process registry would be expensive and difficult to maintain in the case of some kind of partition or failure occurring. The solution to not requiring this is Math! (Consitent-hasing powered HashRings). This reduces the problem of consensus to just a topology data structure and the BEAM VM / Waterpark takes care of the rest.

Due to the guarantees that the topology data structure, powered by HashRings, gives Waterpark, there is only one possible location for a patient process to live. This guarantee means that routing a message to the proper local process registry is trivial given the features of the BEAM VM. Therefore no global registry is required.

## Location Transparency

The distribution capabilities of the BEAM VM was embedded day-one by the creator Joe Armstrong on the premise that “the way it works in the distributed case should be the same for the local case”.

## Mailroom

To extend location transparency from the actor level to the node’s servers the concept of a Mailroom was introduced. Let’s walk through an example.

A messages comes into the system. This message can be received by any node. No one on the outside knows (or cares) about the cluster, HashRings, registries, etc. Each node has a Mailroom. The Mailroom knows the topology. Inbound messages are routed through the Mailroom to the appropriate patient actor. If the patient is remote, the Mailroom routes the message to the remote node’s Mailroom. If the topology changes in-flight, the Mailroom will re-route to the correct Mailroom. The local Mailroom then delivers the message to the correct patient actor. Now the messages is recorded.

The Mailroom provides:

- A nice seam for testing - no need for simulated integration testing, unit testing is possible
- A place to bundle data
- A spot to compress data
- A way to hide complex network logistics (RPC, HTTP, Websockets, etc.)
- A path to distribution replacements - Waterpark currently uses the built-in Erlang distribution but this could be replaced with Phoenix Channels or a combination of multiple mechanisms.

## Patient Actor, Stating the Invariants

- Every patient actor has a key
- Every patient actor is registered (by key) on its node’s registry
- Every patient actor is supervised
- Commands are delivered to a patient actor via the mailroom
- If the patient actor is not running when a command is delivered it will be started
- If the topology has changed and a patient actor’s key no longer maps to its current node, it will migrate to the correct node
- Every patient actor has one read-only follower process (process pair) at each data center
- A patient actor processes commands and emits events
- Before a patient actor commits an event to its event log, two of its four read-only followers must acknowledge receipt of the event
- When a patient actor starts it will ask (via mailroom) if its four read-only followers have state
  - If they do, the patient actor will recover from the “best” reader
- Each patient actor’s state contains its key, an event store, and Map for event handler plugins to store projections

## Deployments

To achieve the zero-downtime requirements of the Waterpark system the following approaches / tools were used:

- Erlang OTP Releases
- Hot code reloading - Sending a new BEAM file, corresponding to a module, to a running BEAM instance. On the next external call (usually via a process making use of the module) of this module, the BEAM file corresponding to the module will be reloaded and execution will carry on with the new implementation.
- Dark launches - a feature is pushed out to the system, placed in the running application’s config. Once the node bounces or a “switch” is explicitly flipped on, the new feature is live. This allows for A/B testing to ensure system integrity across functionality changes
- Universal Server and Plugins - Instead of sending a message to a “server” (a process that handles requests and delivers responses) like a string or some simple data structure, you send a data structure that acts as instructions for that “server”. This allows a once HTTP server to become a now FTP server or whatever server like implementation you can specify with code.

## Event Handler Plugins

To handle the unknown requirements that the COVID-19 pandemic would bring to the Waterpark system the team adopted the idea of the Universal Server to make every patient actor a process capable of becoming any kind of command processing, event emitting, machine it needed to be. This is the idea of Event Handler Plugins.

Practically this means a patient actor state is a map with a key (the actor key), projections (a map containing any required projections for business requirements) an event store (a list of events the patient actor has processed) and a set of event handler plugins. An event handler has a “handle” function with a defined spec that receives the patient actor key, the patient actor’s projections, the message to handle and the history of messages that patient actor has seen before. The specified function returns a tuple of an :ok atom, the new map of projections and the side effects produced when handling that event. This means the specified function of an event handler plugin is a pure function, leading to property-based testing capabilities. This moves the testing of a system to the essence of what the business cares about and not the other parts of a distributed system that are typically cared about such as consensus, availability, durability, etc.

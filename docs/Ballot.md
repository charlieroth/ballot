# Ballot

Ballot's intention is create a software system that uses mechanisms such as
open-source software, consensus, fault-tolerance and social responsibility
to advance the domain of election software.

A Ballot System is intended to be ran by a community, hosting the election,
and 3 other communities to ensure that the responsibility of election
results is spread amongst multiple owners rather than a single community.
This plays on the consensus, fault-tolerance and social mechanisms of
previous software systems such as Bitcoin and others.

Some believe that blockchain technology such as Bitcoin or Ethereum
are the ultimate mechanisms to hold election. While this may be true
in the long-term, the fundamental belief of Ballot is there an
intermediate technological step required to make society familiar with such
systems. While blockchain systems have strong consistency properties for
all software using a blockchain, Ballot believes that eventually consistent
software systems are _good enough_ for election software.

## System Description

Ballot is a distributed, geographically fault-tolerant election and soft
real-time software system with the following attributes:

- RAM based embedded database for storing election data
- Integration Engine for third-parties to interface with election results

## Software Stack

Ballot is built with the Elixir programming language on top of the
Erlang Virtual Machine, providing a rich set of tools for building
fault-tolerant and distributed software systems.

## Mailroom

Inbound messages are routed through a node's _Mailroom_. The _Mailroom_ is the
how location transparency is achieved in a Ballot System. The _Mailroom_ is the
only component of a node that knows about the Topology (see "Cluster Toplogy"
section below).

If an _Election Actor_ is on a remote node, the _Mailroom_ routes the message to
the remote node's _Mailroom_. If the _Topology_ changes when the message is
in-flight, the _Mailroom_ will re-route the message to the correct _Mailroom_.
Once the correct, local, _Mailroom_ receives the message, it is delivered to
the correct _Election Actor_ process. The message then ready to be recorded.

## Election Actor

This main entity in the Ballot System is an _Election Actor_. It processes commands
and emits events.

An _Election Actor_ is an Actor Process, a digital twin of a election being carried
out by humans. An _Election Actor_ is a long-running process that will be alive
for the entirety of an election and for however long those election results are
desired to live in the Ballot system. An _Election Actor_ process is alive for a
minimum of 21 days.

An _Election Actor_ contains all events the entire lifecycle of an election.

An _Election Actor_ is designed as a _Process Pair_, popularized by Jim Gray's
Tandem Computing. Practically, for each election there is a _Writer Process_
which receives and processes all commands for a given election. This
_Writer Process_ also has 4 _Read Replica Processes_ to ensure high
availability of election data.

A message is considered "acknowledged" if the _Election Actor_ writer processes
receives acknowledgement from 2 of it's 4 _Read Replica Processes_

### Election Actor Invariants

- Every _Election Actor_ has a key
- Every _Election Actor_ is registered (by key) on its node’s registry
- Every _Election Actor_ is supervised
- Commands are delivered to a _Election Actor_ via the _Mailroom_
- If the _Election Actor_ is not running when a command is delivered it will
  be started
- If the topology has changed and a _Election Actor_’s key no longer maps to its
  current node, it will migrate to the correct node
- Every _Election Actor_ has one read-only follower process (process pair) at
  each data center
- A _Election Actor_ processes commands and emits events
- Before a _Election Actor_ commits an event to its event log, two of its
  four read-only followers must acknowledge receipt of the event
- When a _Election Actor_ starts it will ask (via _Mailroom_) if its four
  read-only followers have state
  - If they do, the _Election Actor_ will recover from the "best" reader
- Each _Election Actor_'s state contains its key, an event store, and Map for
  event handler plugins to store projections

## Cluster

A running Ballot System is designed to be geographically distributed
to provide high availability. This requires a cluster architecture as follows:

- Designated 4 data centers for election data to be stored in, each having
  2 availability zones
- Each of the 4 data centers runs a total of 8 nodes, 8 physical machines
- The 8 nodes in a data center are split in groups of 4, 4 for each
  availability zone
- Each of the 32 nodes of the entire cluster run an instance of the Ballot
  Software System

To ensure high availability the Ballot System has no "master" nodes,
therefore each running instance is a "peer" or "worker" node.

### Cluster Topology

Expanding on the above points, the cluster topology of a running Ballot Software
System is managed by data structure that uses `HashRing` data structures to
ensure that each running node has a consistent view of where nodes are in the
system and where a _Election Actor_ is running.

By using a shared data structure in the way that Ballot uses it, the concept of
consensus is pushed to the edge of the software system rather than being tangled
in the lower layers of the system.

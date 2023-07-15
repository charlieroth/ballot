# Ballot: The System

Below is a series of paragraphs describing the internals and technological
principles that a Ballot network is built upon.

These topics are heavily inspired and blatantly copied from HCA Healthcare's
"Waterpark" project, Tandem Computers work/research on distributed computing
and the work/research of Joe Armstrong and the Erlang team. These topics also
draw inspiration from CQRS and CDN networks.

## Core Idea

Ballot is "living system" whose only concern is the storage and transformation
of a *Poll*.

A "living system" in the software sense, close to the biological sense, means
that it does everything in it's power to not "turn off". Parts of the system
may sleep or if there is no desired activity on the network, most of the
system could be asleep and awoken on demand. Another aspect of it liviness
is that is can evolve as the demands of the system change

A *Poll* represents a point of inquiry that desires to be recorded
by a group of people. Ballot is only concerned with the state, messages, events
and projections of a *Poll*. State meaning, what point of inquiry this *Poll*
represents, the options of how it can be responded to and it's scope of
accessibility (public, private, open, closed, etc.). Message meaning, an action
that is desired to take place in the system. Event meaning, the ensurance that
a message was received and recorded in the system. Projection meaning, an
alternative view of a *Poll's* current state.

Another point should be made clear about the Ballot system. Ballot has no
"hard" storage. The Ballot software in this codebase at no point writes data
to disk. This simplifies and eliminates concerns of a Ballot system. By
removing the conern of hard storage, Ballot's only consensus concern
is that of the *Nodes* in it's network and not the underlying software
that controls "hard" storage. Of course "hard" storage could be added
in the future however this would storage solution would also require
very similar ideals and guarentees that Ballot offers (e.g., TigerBeetle DB).

## Evolution

The Ballot network is designed for zero downtime. This does not mean
that the network cannot evolve. Surely a network responsible for handling
the voting systems will need to evolve over time to meet new requirement of the
citizens it is serving. This is accomplished using the following ideas:

* OTP Releases
* Hot-code Loading
* Dark Launches
* Unviersal Server and Plugins

## Machines

A Ballot network consists of 5 or more physically separated machines.
Each machine running an instance of the Ballot network software. Ideally
these machines are geographically separated to avoid all kinds of failure.
The reason for 5 or more machines, is due to the replication and consensus
architecture detailed below. Each machine in this network is considered a
*Node* in the Ballot network.

## Nodes

A *Node* is a running instance of the Ballot software system. It can perform
all operations any other *Node* in the network can perform. Some distributed
systems have the concept of "master" and "slave" nodes in the network. There
are no "master" and "slave" nodes in a Ballot network, just *Nodes*. This
ensures all *Nodes* are equal and have all have the same capabilities.

*Nodes* is desgined to have no downtime and can recover from any kind of
failure. This is achieved by a *Node* being a function of a series messages.
This series of messages can either come from a client "interacting" with a
*Node* or another *Node* reconstructing a *Node*. In the Ballot network,
reconstruction is a costly operation however due to the gaurentees the system
is provided by the BEAM, is should be rare and therefore it is a tolerated
cost.

## The Mailroom

To have location transparency at the actor level and the node level, the
concept of a *Mailroom* is used. Each *Node* is a peer in the network and
any node can receive a message. Each *Node* has a *Mailroom*, the *Mailroom*
knows the topology of the network. Inbound messages are routed through
the *Mailroom* to the appropriate *Poll* actor. If the *Poll* actor is
"remote" then it is routed to the *Node* holding that *Poll* actor, then
the "local" *Mailroom* delivers the message to the correct *Poll* actor.

The *Mailroom* provides:

* Nice boundary for testing the network
* Place to bundle data
* Place to compress data if necessary
* Hide the details of `:rpc`
* A Path to distribution replacements
  * This means the underlying "channel" of distribution could be replaced
    with Phoenix Channels, Websockets, etc.

## Processes

There is a single *process* in the Ballot network, a *Poll* process.
This is the source of consensus for a poll created by a client.
A *Poll*, like a *Node*, is a function of a series of messages.

## *Poll* Actor

Stating The Invariants:

* Every Poll Actor has a key.
* Every Poll Actor is registered (by key) on it's Node's Registry.
* Every Poll Actor is Supervised.
* Messages are delivered to a Poll Actor via the Mailroom.
* If the Poll Actor is not running when a message is delivered it will
  be started.
* If Topology has changed and a Poll Actor's key no longer maps to
  its current Node, it will migrate to the correct Node.
* Every Poll Actor has one read-only follower process (process pair)
  at each datacenter.
* A Poll Actor processes messages and emits events.
* Before a Poll Actor commits an event to its event log, two of its four
  read-only followers must acknowledge receipt of the event.
* When a Poll Actor starts it will ask (via Mailroom) if its four
  read-only followers have state. If they do, the Poll Actor will recover
  from the "best" reader.
* Each Poll Actor's state contains its key, an event store, and a Map
  for event handler plugins to store projections.

*Poll* processes live in a place. This place is mathematically significant
by using *Server HashRings*. A *Poll* process has a UUID that is used to map
the *Poll* process to the place it lives. This means that as long as you have
the *Poll* process UUID, you know how to route an event to this process.

A *Poll* Actor looks like this:

```elixir
%{
  key: %{id: "eca6fb3e-2f61-4496-85af-767a7713d432", zone: "MI-734"},
  projections: %{...},
  event_store: [...]
}
```

A *Poll* Actor has a collection of event-handler plugins that are ideally
loaded at deploy-time but can also be loaded in run-time

An event-handler plugin has the following contract:

```elixir
@spec handle(
  key :: map(),
  projections :: projections(),
  msg :: Message.t(),
  history: [Message.t()]
) :: {:ok, projections(), side_effects()}
```

This contract is a pure function which allows for complex logic to live
inside the function itself and still have an easy surface to do property-based
testing on to ensure the underlying logic can handle all cases.

### Process Pairs

Each *Poll* process has several "pairs". This concept is borrowed from
"Process Pairs" or "Tandem Computing"; created by Tandem Computers in
the 1970s and 1980s in order to construct fault-tolerant computer
systems which required maximum uptime and zero data loss.

This means a *Poll* process will have a *writer* process and 4 *read replica*
processes; it's pairs. Every time a message is received by the *writer* process,
this message is also sent to other the 4 *read replicas*.

In the case of a *read replica* process crashing while messages are in flight,
the consensus algorithm of the process pairs states that the *writer* process
must receive at least 3 "acks" before it may continue with the next message.
This is to ensure data each *writer* process has a "digital twin" that in
the case of a *writer* process crashing, it can be successfully reconstructed
and recovers state from the nearest, best *read replica* process.

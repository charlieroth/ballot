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

[Mailroom.md](/docs/Mailroom.md)

## Election

[Election.md](/docs/Election.md)

## Cluster Topology

[Topology.md](/docs/Topology.md)

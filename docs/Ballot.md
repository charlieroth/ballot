# Ballot

Ballot is a distributed, geographically fault-tolerant election and soft real-time
software system with the following attributes:

* RAM based embedded database for storing election data
* Integration Engine for third-parties to interface with election results

## Software Stack

Ballot is built with the Elixir programming language on top of the
Erlang Virtual Machine, providing a rich set of tools for building
fault-tolerant and distributed software systems.

## System Architecture

### Election Actor

An Election Actor is an Actor Process, a digital twin of a election being carried
out by humans. An Election Actor is a long-running process that will be alive for
the entirety of an election and for however long those election results are desired
to live in the Ballot system.

An Election Actor contains all events the entire lifecycle of an election.
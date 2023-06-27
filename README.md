# Ballot

An experiment to see the viability of building a voting system
in Elixir, Erlang and the BEAM

## Thesis

Voting should be *correct*, *decentralized* and *fault-tolerant*.

The U.S. must evolve it's voting system into the modern
technological age of distributed, consensus driven and open-source
software.

Cities, counties, states and countries must embrace software engineering
to develop productive, open and iterative societies.

Ballot aims to be an example of how this can and should be done

## Capabilities & Architecture

Ballot aims to become a voting network desgined for voting on the scale of
hundreds of millions of participants. Ballot should be capable of hosting
city, county, state and presidential elections.

Technically speaking, this will be achieved through the powerful clustering
abstractions that the BEAM, Erlang, Elixir and OTP have to offer. The combination
of these technologies is the best civilization has at the moment to build
systems that the modern, technological world demands.

## How Does Ballot Work

### Meet the Processes

There a single *process* in the Ballot network, a *poll*. A *poll*
is the source of consensus for the question(s) being asked to a
group of people, therefore it is the only thing that should live
in the system that is Ballot.

Today's applications have concepts of users and databases which
personalize and centralize data storage. Ballot is a network and
software system

### Pair Processing

Starting from the lowest level in Ballot, the *processes*. Each
process in the Ballot network operates with a "Process
Pair" or the concept of "Tandem Computing", which was created by
Tandem Computers in the mid-to-late 1970s.

For example, a *Poll* process will have a *writer* process and 4 *read replica*
processes. Every time a message is received by the *writer* process, this
message is also sent to other the 4 *read replicas*. Of course *read replica*
processes could crash while messages are in flight, so the consensus algorithm
of the process pairs states that the *writer* process must receive at least 3
"acks" before it may continue with the next message. In the case of the
*writer* process crashing, a new *writer* process will be spawn in its place,
in the availability zone, and recovers state from the nearest, best *read replica*
process.

### Voting & Availability Zones

TODO

## Links

[Tandem & NonStop Computing](https://cs.stanford.edu/people/eroberts/courses/soco/projects/2003-04/fault-tolerant-computing/how-tandem.html)

[Tandem Computers: Wikipedia](https://en.wikipedia.org/wiki/Tandem_Computers)

[github.com/bitwalker/libring](https://github.com/bitwalker/libring)

[GigCityElixir 2023: Bryan Hunter](https://www.youtube.com/watch?v=pQ0CvjAJXz4)

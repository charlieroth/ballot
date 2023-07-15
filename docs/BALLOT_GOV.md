# Ballot

An experiment to explore what an election network built on the BEAM would
look like. Ballot can be thought of as a CDN network for voting systems. Ballot does not handle the permanent storage results of an election but instead
directs the information traffic and stores all events conerning an election
from the time it starts until the completion of an election.

## Hypothesis

Elections should be *transparent*, *decentralized*, *fault-tolerant* and
*verifiable*. These listed principles are essentially what a blockchain
provides. The election network people and government desire do not require
blockchain, it requires these blockchain principles. I argue the principles of
blockchain technology are the real innovation, not the full implementation
of a blockchain itself.

A blockchain should be used for the permanent storage of election results
however the potentially millions of events that occur during an election should
not be stored in a blockchain but live in a running network until the election
is complete.

Breaking down the first sentence:

### Transparent

Software that processes voting should be managed by Git, open-source and
invite-only contribution. This ensure there is a cryptographically recorded
history of the codebase, the code is built in an open manner and the quality
of contributors is high. Too much of the world looks at software as a black
box and with increasingly powerful technologies entering society, it is
important that this is built by humans, for humans.

Every election that takes place should be observable from the internet in as
close to real-time as possible. It is irresponsible for a society to not to
have this level of transparency in a system that influences the people that
occupy it.

The network of computation required to host an election should be public
knowledge, the physical location of the machines used, what machines the
software is running on, the operating system it is using, the programming
language/environment used to create the Ballot software, etc. This could
be considered a security risk to certain parties and they would be correct.
However, it is much better to be honest than to use black box, private
government contracted software that no one other than the people who
created it have seen.

### Decentralized

Every election should be partially hosted and accounted for by another
jurisdiction, meaning the compute required for an election to begin, operate
and finalize should be shared amongst at least 5 computers that are
physically separated in a Ballot network.

To run and maintain these physical machines this will require jurisdictions
to hire IT professionals that are government employees. These people will be
on a public record for easy accountability. Large tech companies and especially
"cloud" companies are not allowed in this system not because they should be
inherently viewed as bad actors, but because it is time for governments and
everyday people to take software as seriously as it deserves to be. The world
needs to create incentive for IT professionals to want to work on humanitarian
technology unlike the current state of IT which is majority capital growth
driven technology.

### Fault-Tolerant

Every election should be able to recover in case the Ballot network fails.

Fault-tolerance is spoken about in the software engineering community often
and is heavily debated. Usually if humans are still debating something as much
as fault-tolerance is, this means they don't understand it all that well. So
despite the amount of conversation around fault-tolerant software systems, the
number of implementations of fault-tolerant systems is embarassingly low. This
is the case because fault-tolerance is difficult and there is very little financial
incentive to fault-tolerance

The concept of fault-tolerance is very foreign to humansand non-technically
focused people have a naive understanding about the fault-tolerance of software
systems today.

## Capabilities & Architecture

Ballot aims to become a voting network desgined for voting on the scale of
hundreds of millions of participants. Ballot should be capable of hosting
city, county, state and presidential elections.

Technically speaking, this will be achieved through the powerful clustering
abstractions that the BEAM, Erlang, Elixir and OTP have to offer.

## How Does Ballot Work



## References

[GigCityElixir 2023: Bryan Hunter](https://www.youtube.com/watch?v=pQ0CvjAJXz4)

[Tandem & NonStop Computing](https://cs.stanford.edu/people/eroberts/courses/soco/projects/2003-04/fault-tolerant-computing/how-tandem.html)

[Tandem Computers: Wikipedia](https://en.wikipedia.org/wiki/Tandem_Computers)

[Consistent Hashing: Wikipedia](https://en.wikipedia.org/wiki/Consistent_hashing)

[Consistent Hashing and Random Trees: Distributed Caching Protocols for Relieving Hot Spots on the World Wide Web](https://www.cs.princeton.edu/courses/archive/fall09/cos518/papers/chash.pdf)

[https://github.com/bitwalker/libring](https://github.com/bitwalker/libring)

[EventStoreDB: Projections Business Cases](https://developers.eventstore.com/server/v5/projections.html#business-case-examples)

[Joe Armstrong: Universal Server](https://joearms.github.io/published/2013-11-21-My-favorite-erlang-program.html)

[Elixir: Releases](https://elixir-lang.org/getting-started/mix-otp/config-and-releases.html#releases)

## WIP


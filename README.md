# Ballot

Ballot is an experiment in building a distributed, geographically
fault-tolerant, RAM based, embedded database for holding elections.

Ballot is built with Elixir and minimal dependencies.

Ballot is based on previous work done HCA Healthcare, [Project Waterpark](https://www.youtube.com/watch?v=pQ0CvjAJXz4). Notes on the Waterpark system can be found in [Waterpark.md](/docs/Waterpark.md)

For an in-depth explaination of the Ballot system see [Ballot.md](/docs/Ballot.md)

## Dependencies

### `libring`

[bitwalker/libring](https://github.com/bitwalker/libring)

`libring` is used for a `HashRing` implementation. `libring` provides a simple
and fast implementation of consistent hash rings. This is used within `ballot`
for synchronizing cluster topology.

### `libcluster`

[bitwalker/libcluster](https://github.com/bitwalker/libcluster) - For cluster membership discovery

`libcluster` is used as the mechanism for automatically forming clusters of
Erlang nodes. With is pluggable "strategy" system the cluster formation and
maintenance of the cluster can evolve as system requirements evolve.

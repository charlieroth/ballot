# Topology

Ballot is designed to be geographically distributed to provide high
availability. This requires:

- 4 designated data centers
- Each of the 4 data centers runs a total of 8 nodes
- The 8 nodes are split in 2 groups of 4, forming availability zones
- The 32 nodes of the cluster run an instance of Ballot

Ballot has no "master" nodes, each node is a "peer" node.

## Cluster Membership

When a node joins the cluster, a singal is sent to all other nodes in the system,
the new `Topology` state is then computed from the current set of connected nodes.

When a node leaves the cluster a signal is sent to all other nodes in the system,
the new `Topology` state is then computed from the current set of connected nodes.

### Topology State

`Topology` state is a pure function of the current list of connected nodes in the
cluster whose result is a `HashRing` data structure ensuring a deterministic view
of the cluster. This behavior pushes consensus to the edge of the system rather
than leaking into the core of the system.

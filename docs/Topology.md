# Topology

A running Ballot System is designed to be geographically distributed
to provide high availability. This requires a cluster topology as follows:

- Designated 4 data centers for election data to be stored in, each having
  2 availability zones
- Each of the 4 data centers runs a total of 8 nodes, 8 physical machines
- The 8 nodes in a data center are split in groups of 4, 4 for each
  availability zone
- Each of the 32 nodes of the entire cluster run an instance of the Ballot
  Software System

To ensure high availability the Ballot System has no "master" nodes,
therefore each running instance is a "peer" or "worker" node.

## Implementation

When a Node in a Ballot System is started, it forms a connection to the cluster
via the `Ballot.ClusterSupervisor` which is using `bitwalker/libcluster` to
manage the formation and monitoring of the cluster based on a strategy.

When a Node joins the cluster a singal is sent to all other nodes in the system,
the `Ballot.ClusterSupervisor` captures this membership change and at the same time
the monitoring process `Ballot.Topology` also receives a message via
`handle_info({:nodeup, node}, state)`. Once this message is received the current
list of connected Nodes is retrieved via `Node.list()`. This list of connected
Nodes serves as the input to derive the new Topology state.

When a Node exits the cluster a signal is sent to all other nodes in the system,
the same behavior as above occurs, a message is received via
`handle_info({:nodedown, node}, state)`, new Topology state is computed.

### Topology State

The cluster topology is managed by sharing a `HashRing` data structure ensuring
that each running node has a consistent view of where nodes are in the system
and where a _Election Actor_ is running.

By using a shared data structure in the way that Ballot uses it, the concept of
consensus is pushed to the edge of the software system rather than being tangled
in the lower layers of the system.


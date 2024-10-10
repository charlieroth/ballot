# Election

This main actor in the Ballot System is an `Election`. It processes commands
and emits events.

An `Election` is an actor process, a digital twin of a election being carried
out by humans. An `Election` is a long-running process that will be alive
for the entirety of an election and for however long those election results are
desired to live in the Ballot system. An `Election` process is alive for a
minimum of 21 days.

An `Election` contains all events the entire lifecycle of an election.

An `Election` is designed as a _Process Pair_, popularized by Jim Gray's
Tandem Computing. Practically, for each election there is a _Writer Process_
which receives and processes all commands for a given election. This
_Writer Process_ also has 4 _Read Replica Processes_ to ensure high
availability of election data.

A message is considered "acknowledged" if the `Election` writer processes
receives acknowledgement from 2 of it's 4 _Read Replica Processes_

## Invariants

- Every `Election` has a key
- Every `Election` is registered (by key) on its node’s registry
- Every `Election` is supervised
- Commands are delivered to a `Election` via the `Mailroom`
- If the `Election` is not running when a command is delivered it will
  be started
- If the topology has changed and a `Election`’s key no longer maps to its
  current node, it will migrate to the correct node
- Every `Election` has one read-only follower process (process pair) at
  each data center
- A `Election` processes commands and emits events
- Before a `Election` commits an event to its event log, two of its
  four read-only followers must acknowledge receipt of the event
- When a `Election` starts it will ask (via `Mailroom`) if its four
  read-only followers have state
  - If they do, the `Election` will recover from the "best" reader
- Each `Election`'s state contains its key, an event store, and Map for
  event handler plugins to store projections

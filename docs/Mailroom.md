# Mailroom

The `Mailroom` is the how location transparency is achieved in Ballot.

The `Mailroom` is a process that is aware of the cluster's `Topology`
and routes messages to the correct, local or remote, `Election` process.

## Message Routing

When the `Mailroom` receives a message, it uses the `Topology` to find
the location of the intended `Election` process in the cluster.

If an `Election` process is on a remote node, the `Mailroom` routes the message
to the remote node's `Mailroom`.

Because the `Mailroom` relies on the `Topology` to tell it where the intended
`Election` process is, if the `Topology` changes when the message is in-flight,
the `Mailroom` will re-route the message to the correct node's `Mailroom`.

Once the correct, local, `Mailroom` receives the message, it is delivered to
the correct `Election` process. The message then ready to be processed.

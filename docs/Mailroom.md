# Mailroom

The `Mailroom` a process in a node that is aware of the `Topology`.

The `Mailroom` is responsible for routing messages to the correct `Election`
process.

This is achieved by using the `Topology` to determine the location of the
`Election` process and then routing the message to the correct node.

## Message Routing

Inbound messages are routed through a node's `Mailroom`.

The `Mailroom` is the how location transparency is achieved in Ballot.

If an `Election` process is on a remote node, the `Mailroom` routes the message
to the remote node's `Mailroom`.

If the `Topology` changes when the message is in-flight, the `Mailroom` will
re-route the message to the correct `Mailroom`.

Once the correct, local, `Mailroom` receives the message, it is delivered to
the correct `Election` process. The message then ready to be processed.

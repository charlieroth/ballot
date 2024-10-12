# Mailroom

The `Mailroom` enables location transparent delivery of messagse.

A `Mailroom` is aware of the cluster's `Topology`, routing messages to the
correct (local or remote) `Election`.

## Message Routing

When the `Mailroom` receives a message, it uses the `Topology` to find
the location of the intended `Election` in the cluster.

If an `Election` is on a remote node, the `Mailroom` routes the message
to the remote node's `Mailroom`.

If the `Topology` changes while a message is in-flight, the `Mailroom`
will re-route the message to the correct node's `Mailroom`.

Once the correct `Mailroom` receives the message, it is delivered to
the correct `Election` for processing.

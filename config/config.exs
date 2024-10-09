import Config

config :libcluster,
    topologies: [
      ballot: [
        strategy: Cluster.Strategy.LocalEpmd,
      ]
    ]

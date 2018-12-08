{
  global: {
    // User-defined global parameters; accessible to all component and environments, Ex:
    // replicas: 4,
  },
  components: {
    // Component-level parameters, defined initially from 'ks prototype use ...'
    // Each object below should correspond to a component in the components/ directory
    "bg-guestbook": {
      containerPort: 80,
      image: "gcr.io/heptio-images/ks-guestbook-demo:0.2",
      name: "blue-green-guestbook",
      replicas: 3,
      servicePort: 80,
      type: "LoadBalancer",
    },
    "bg-pod": {},
  },
}

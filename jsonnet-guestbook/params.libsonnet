{
  containerPort: 80,
  image: "gcr.io/google-samples/gb-frontend:v5",
  name: "jsonnet-guestbook-ui",
  replicas: 1,
  servicePort: 80,
  type: "LoadBalancer",
}

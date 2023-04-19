---
cat <<EOF >./kustomization.yaml
secretGenerator:
- name: mysql-pass
  literals:
  - password=YOUR_PASSWORD
EOF
---
curl -LO https://k8s.io/examples/application/wordpress/mysql-deployment.yaml
---
curl -LO https://k8s.io/examples/application/wordpress/wordpress-deployment.yaml
---
cat <<EOF >>./kustomization.yaml
resources:
  - mysql-deployment.yaml
  - wordpress-deployment.yaml
EOF
---
kubectl apply -k ./
---
kubectl get secrets
---
kubectl get pvc
---
kubectl get pods
---
kubectl get services wordpress
---
kubectl delete -k ./

https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/
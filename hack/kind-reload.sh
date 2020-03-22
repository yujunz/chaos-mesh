#!/usr/bin/env bash
set -e

make image-chaos-mesh image-chaos-daemon manifests

for image in pingcap/chaos-mesh pingcap/chaos-daemon
do
    kind load docker-image $image --name ${1:-kind}
done

kubectl apply -f manifests/crd.yaml
helm upgrade --install chaos-mesh helm/chaos-mesh --namespace=chaos-testing --set=chaosDaemon.imagePullPolicy=IfNotPresent --set=controllerManager.imagePullPolicy=IfNotPresent
kubectl rollout restart deployment chaos-controller-manager -n chaos-testing
kubectl rollout restart daemonset chaos-daemon -n chaos-testing

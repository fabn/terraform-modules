#!/bin/sh

# Install cert-manager CRDs before running terraform test to ensure they exists:
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.6.3/cert-manager.crds.yaml

#!/bin/sh

mkdir tmp
git clone https://github.com/bank-vaults/vault-operator.git --depth 1 tmp/vault-operator
git clone https://github.com/elastic/crd-ref-docs.git --depth 1 tmp/crd-ref-docs
cd tmp/crd-ref-docs; go run main.go \
    --source-path=../vault-operator/pkg/apis/vault/v1alpha1/ \
    --config=../../crd-ref-docs-custom-files/config.yaml \
    --renderer=markdown --templates-dir=../../crd-ref-docs-custom-files
mv out.md ../../../content/docs/operator/reference.md
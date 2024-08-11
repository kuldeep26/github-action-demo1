#!/bin/bash




set -e

annotate_istio_svc_with_alb_health_check() {
  local service_name="istio-ingressgateway"
  local namespace="istio-system"

  healthcheck_path=$(kubectl -n "${namespace}" get deployment "${service_name}" -o json | \
                     jq -r '.spec.template.spec.containers[].readinessProbe.httpGet.path')

  healthcheck_port=$(kubectl -n "${namespace}" get svc "${service_name}" -o json | \
                     jq -r '.spec.ports[] | select( .name | contains("status-port")) | .nodePort')

  kubectl annotate svc "${service_name}" -n "${namespace}" "alb.ingress.kubernetes.io/healthcheck-path=${healthcheck_path}" --overwrite
  kubectl annotate svc "${service_name}" -n "${namespace}" "alb.ingress.kubernetes.io/healthcheck-port=${healthcheck_port}" --overwrite
}

annotate_istio_svc_with_alb_health_check "$@"
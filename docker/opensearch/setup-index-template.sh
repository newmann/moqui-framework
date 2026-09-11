#!/bin/sh
set -e

OS_URL="${OPENSEARCH_URL:-https://moqui-search:9200}"
USER="${OPENSEARCH_USER:-admin}"
PASS="${OPENSEARCH_PASSWORD:-MoquiElasticChangeMe@2026}"
TEMPLATE_FILE="${TEMPLATE_FILE:-/index-template-zh.json}"

echo "Waiting for OpenSearch at ${OS_URL}..."
i=0
until curl -skf -u "${USER}:${PASS}" "${OS_URL}" >/dev/null 2>&1; do
    i=$((i + 1))
    if [ "$i" -ge 90 ]; then
        echo "OpenSearch did not become ready in time"
        exit 1
    fi
    sleep 2
done

echo "Putting index template moqui_zh..."
curl -skf -u "${USER}:${PASS}" -X PUT "${OS_URL}/_index_template/moqui_zh" \
    -H "Content-Type: application/json" \
    --data-binary "@${TEMPLATE_FILE}"
echo
echo "Index template moqui_zh installed."

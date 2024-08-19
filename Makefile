OPENSEARCH_VERSION:= 2.21.0
OPENSEARCH_DASHBOARD_VERSION:= 2.19.1

helm:
	helm repo add opensearch https://opensearch-project.github.io/helm-charts/
	helm repo update opensearch

opensearch:
	helm template opensearch opensearch/opensearch --version=${OPENSEARCH_VERSION} --values=values-opensearch-master.yaml > helm-opensearch-master.yaml
	helm template opensearch opensearch/opensearch --version=${OPENSEARCH_VERSION} --values=values-opensearch-worker.yaml > helm-opensearch-worker.yaml

dashboard:
	helm template opensearch opensearch/opensearch-dashboards --version=${OPENSEARCH_DASHBOARD_VERSION} --values=values-opensearch-dashboard.yaml > helm-opensearch-dashboard.yaml

run-dump: 
	kubectl kustomize .

dump:  opensearch run-dump

run-apply:  
	kubectl apply -k .

apply:  get-secrets opensearch dashboard run-apply clean-secrets

run-destroy:
	kubectl delete -k .

destroy:  opensearch dashboard run-destroy

get-secrets:
	mkdir -p opensearch/etc/.secrets
	vault kv get --field=<secret name> secret/rubin/usdf-opensearch/opensearch > opensearch/etc/.secrets/<secret file>

clean-secrets:
	rm -rf opensearch/etc/.secrets

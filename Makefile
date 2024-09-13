OPENSEARCH_VERSION:= 2.21.0
OPENSEARCH_DASHBOARD_VERSION:= 2.19.1

helm:
	helm repo add opensearch https://opensearch-project.github.io/helm-charts/
	helm repo update 
	
opensearch: nodes dashboard

nodes:
	helm template opensearch opensearch/opensearch --version=${OPENSEARCH_VERSION} --values=values-opensearch-master.yaml > helm-opensearch-master.yaml
	helm template opensearch opensearch/opensearch --version=${OPENSEARCH_VERSION} --values=values-opensearch-worker.yaml > helm-opensearch-worker.yaml
	helm template opensearch opensearch/opensearch --version=${OPENSEARCH_VERSION} --values=values-opensearch-coordinator.yaml > helm-opensearch-coordinator.yaml


dashboard:
	helm template opensearch opensearch/opensearch-dashboards --version=${OPENSEARCH_DASHBOARD_VERSION} --values=values-opensearch-dashboard.yaml > helm-opensearch-dashboard.yaml

run-dump: 
	kubectl kustomize .

dump:  get-secrets opensearch dashboard run-dump

run-apply:  
	kubectl apply -k .

apply: helm get-secrets opensearch run-apply clean-secrets

run-destroy:
	kubectl delete -k .

destroy: get-secrets opensearch dashboard run-destroy clean-secrets

get-secrets:
	mkdir -p opensearch/etc/.secrets
	vault kv get --field=hostcert secret/rubin/usdf-opensearch/opensearch > opensearch/etc/.secrets/hostcert.pem
	vault kv get --field=hostkey secret/rubin/usdf-opensearch/opensearch > opensearch/etc/.secrets/hostkey.pem
	vault kv get --field=password secret/rubin/usdf-opensearch/opensearch > opensearch/etc/.secrets/password
	vault kv get --field=admin-user secret/rubin/usdf-opensearch/opensearch > opensearch/etc/.secrets/username
	vault kv get --field=cookie secret/rubin/usdf-opensearch/opensearch > opensearch/etc/.secrets/cookie
	vault kv get --field=usdf-cacert secret/rubin/usdf-opensearch/opensearch > opensearch/etc/.secrets/root-ca.pem

get-config:
	mkdir -p opensearch/etc/config
	vault kv get --field=internal_users secret/rubin/usdf-opensearch/config > opensearch/etc/config/internal_users.yml
	vault kv get --field=roles secret/rubin/usdf-opensearch/config > opensearch/etc/config/roles.yml
	vault kv get --field=allowlist secret/rubin/usdf-opensearch/config > opensearch/etc/config/allowlist.yml
	vault kv get --field=tenants secret/rubin/usdf-opensearch/config > opensearch/etc/config/tenants.yml
	vault kv get --field=nodes_dn secret/rubin/usdf-opensearch/config > opensearch/etc/config/nodes_dn.yml

put-config:
	vault kv put secret/rubin/usdf-opensearch/config internal_users=@opensearch/etc/config/internal_users.yml roles=@opensearch/etc/config/roles.yml allowlist=@opensearch/etc/config/allowlist.yml nodes_dn=@opensearch/etc/config/nodes_dn.yml tenants=@opensearch/etc/config/tenants.yml

clean-config:
	rm -rf opensearch/etc/config

clean-secrets:
	rm -rf opensearch/etc/.secrets

.PHONY:
docker-springboot:
	mvn clean package docker:build -DskipTests

.PHONY:
docker-springboot-run:
	docker run -p 9090:8080 -t docker.mycompany.com/spring-rest-mysql:latest

.PHONY:
set-up-kind: docker-springboot
	kind create cluster --config=manifests/kind.yaml && \
	kind load docker-image docker.mycompany.com/spring-rest-mysql:latest --name kind && \
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml && \
	sleep 10 && \
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=500s && \
	kustomize build manifests | kubectl apply -f -

.PHONY:
manifests:
	kustomize build manifests | kubectl apply -f -

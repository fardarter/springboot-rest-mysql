.PHONY: docker-springboot
docker-springboot:
	mvn clean package docker:build -DskipTests

.PHONY: docker-nmig-loader
docker-nmig-loader:
	docker build . -t nmig-loader
	

.PHONY: docker-springboot-and-load
docker-springboot-and-load:
	mvn clean package docker:build -DskipTests && \
	kind load docker-image docker.mycompany.com/spring-rest-mysql:latest --name kind

.PHONY: docker-nmig-loader-and-load
docker-nmig-loader-and-load:
	docker build . -t nmig-loader && \
	kind load nmig-loader:latest --name kind

.PHONY: docker-springboot-run
docker-springboot-run:
	docker run -p 9090:8080 -t docker.mycompany.com/spring-rest-mysql:latest

.PHONY: set-up-kind
set-up-kind: docker-springboot docker-nmig-loader
	kind create cluster --config=manifests/kind.yaml && \
	kind load docker-image docker.mycompany.com/spring-rest-mysql:latest nmig-loader:latest --name kind && \
	kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml && \
	sleep 10 && \
	kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=500s && \
	kustomize build manifests | kubectl apply -f -

.PHONY: manifests

.PHONY: manifests
manifests:
	kustomize build manifests | kubectl apply -f -


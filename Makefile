NAME = mutateme
IMAGE_PREFIX = pankydcoder
IMAGE_NAME = $$(basename `pwd`)
IMAGE_VERSION = latest

export GO111MODULE=on

app: deps
	go build -v -o $(NAME) main.go

deps:
	go get -v ./...

test: deps
	go test -v ./... -cover

docker:
	docker build --no-cache -t $(IMAGE_PREFIX)/$(IMAGE_NAME):$(IMAGE_VERSION) .
	docker tag $(IMAGE_PREFIX)/$(IMAGE_NAME):$(IMAGE_VERSION) $(IMAGE_PREFIX)/$(IMAGE_NAME):latest

push:
	@echo "WARNING: if you push to a public repo, you're pushing ssl key & cert, are you sure? [CTRL-C to cancel, ANY other to continue]"
	@sh read -n 1
	docker push $(IMAGE_PREFIX)/$(IMAGE_NAME):$(IMAGE_VERSION)
	docker push $(IMAGE_PREFIX)/$(IMAGE_NAME):latest

kind:
	kind create cluster --config kind.yaml

deploy:
	export KUBECONFIG=$$(kind get kubeconfig-path --name="kind"); kubectl apply -f charts/cc-config-injector/

reset:
	export KUBECONFIG=$$(kind get kubeconfig-path --name="kind"); kubectl delete -f charts/cc-config-injector/
	kind delete cluster --name kind

.PHONY: docker push kind deploy reset
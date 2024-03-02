.DEFAULT_GOAL := help

export ACL_MODE := "priv"

.PHONY: build-image
build-image:
	docker build . -t mysquid --build-arg ACL_MODE=$(ACL_MODE)

.PHONY: up
up:
	docker run --rm -itd --network host --name mysquid mysquid

.PHONY: down
down:
	docker stop mysquid
	sleep 2

.PHONY: restart
restart: build-image down up

.PHONY: help
help: ## ヘルプ表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

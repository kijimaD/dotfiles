.DEFAULT_GOAL := help

export ACL_MODE := "priv"

.PHONY: build-image
build-image: ## 指定されたモードに基づいてイメージをビルドする。指定しない場合は値privが使われる。priv || work || disable
	docker build . -t mysquid --build-arg ACL_MODE=$(ACL_MODE)

.PHONY: up
up: ## コンテナを起動する
	docker run --rm -itd --network host --name mysquid mysquid

.PHONY: down
down: ## コンテナを破棄する
	docker stop mysquid
	sleep 2

.PHONY: restart
restart: build-image down up

.PHONY: help
help: ## ヘルプ表示
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

# Root Makefile — scarymovie/protos
# ----------------------------------------------------------
# Можно переопределять в env: make push BSR=buf.build/ORG/MOD
BUF              ?= $(shell command -v buf)
BSR 			 ?= buf.build/scarymovie/protos:v2   # публикуем как major-v2
PROTO_DIR        ?= .

.PHONY: buf-check lint breaking update push clean help

buf-check:        ## Проверка наличия buf CLI
	@if [ -z "$(BUF)" ]; then \
	    echo "ERROR: buf CLI не найден. Установите его и/или добавьте в PATH."; \
	    exit 1; \
	fi

## Обновить deps (buf.lock)
update: buf-check
	$(BUF) dep update

## Линтер (buf lint)
lint: buf-check
	$(BUF) lint $(PROTO_DIR)

## Проверить breaking-changes относительно последнего пуша
breaking: buf-check
	$(BUF) breaking --against $(BSR)

## Опубликовать модуль в BSR
push: lint breaking buf-check
	@echo ">> pushing to $(BSR)"
	$(BUF) push $(BSR)

## Очистить кэш buf (опционально)
clean: buf-check
	$(BUF) clean

## Подсказка
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-12s\033[0m %s\n", $$1, $$2}'

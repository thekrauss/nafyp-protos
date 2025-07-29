SHELL := /bin/bash 

PROTO_DIRS := auth controle kubemanager worker
OUT_DIR := gen/go
GOOGLE_PROTOS := third_party/googleapis
COMMIT_MSG ?= "Mise à jour des stubs gRPC + gRPC-Gateway"

# Récupère le dernier tag et incrémente le patch
LAST_TAG := $(shell git tag --sort=-version:refname | head -n 1)
ifeq ($(LAST_TAG),)
    NEW_TAG := v0.1.0
else
    NEW_TAG := $(shell \
        v=$(LAST_TAG); \
        v=$${v#v}; \
        IFS=. read -r X Y Z <<< "$$v"; \
        Z=$$((Z+1)); \
        echo v$$X.$$Y.$$Z \
    )
endif

all: clean generate commit-tag

generate:
	@mkdir -p $(OUT_DIR)
	@for dir in $(PROTO_DIRS); do \
		if [ -d $$dir ] && ls $$dir/*.proto 1> /dev/null 2>&1; then \
			echo "📦 Compilation de $$dir..."; \
			mkdir -p $(OUT_DIR)/$$dir; \
			protoc -I $$dir -I . -I $(GOOGLE_PROTOS) \
			       --go_out=$(OUT_DIR)/$$dir \
			       --go-grpc_out=$(OUT_DIR)/$$dir \
			       --grpc-gateway_out=$(OUT_DIR)/$$dir \
			       --go_opt=paths=source_relative \
			       --go-grpc_opt=paths=source_relative \
			       --grpc-gateway_opt=paths=source_relative \
			       $$dir/*.proto; \
		else \
			echo "⚠️  Dossier $$dir ignoré (vide ou sans .proto)"; \
		fi \
	done

commit-tag:
	@git add $(OUT_DIR)
	@git commit -m "$(COMMIT_MSG)" || echo "⚠️  Rien à valider"
	@git push origin main
	@git tag $(NEW_TAG)
	@git push origin $(NEW_TAG)
	@echo "✅ Nouveau tag créé : $(NEW_TAG)"

clean:
	rm -rf $(OUT_DIR)

.PHONY: all generate clean commit-tag

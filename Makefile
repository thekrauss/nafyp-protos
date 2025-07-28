PROTO_DIRS := auth controle kubemanager worker
OUT_DIR := gen/go
GOOGLE_PROTOS := third_party/googleapis

all: clean generate

generate:
	@mkdir -p $(OUT_DIR)
	@for dir in $(PROTO_DIRS); do \
		if [ -d $$dir ] && ls $$dir/*.proto 1> /dev/null 2>&1; then \
			echo "Compilation de $$dir"; \
			protoc -I $$dir -I . -I $(GOOGLE_PROTOS) \
			       --go_out=$(OUT_DIR) \
			       --go-grpc_out=$(OUT_DIR) \
			       --go_opt=paths=source_relative \
			       --go-grpc_opt=paths=source_relative \
			       $$dir/*.proto; \
		else \
			echo "Dossier $$dir ignoré (vide ou sans .proto)"; \
		fi \
	done

clean:
	rm -rf $(OUT_DIR)

.PHONY: all generate clean

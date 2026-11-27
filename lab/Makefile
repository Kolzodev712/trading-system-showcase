ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
COMPOSE := docker compose --project-directory $(ROOT) -f $(ROOT)/compose.yaml

.PHONY: doctor build demo status logs reset stop verify bundle scenario qualify

doctor:
	sh $(ROOT)/scripts/doctor.sh

build:
	sh $(ROOT)/scripts/stage-sources.sh
	docker pull mongo:7.0
	docker pull envoyproxy/envoy:v1.31.5
	$(COMPOSE) build

demo:
	$(COMPOSE) up -d --no-build --pull never
	@echo "waiting for the runner health endpoint"
	@i=0; while [ $$i -lt 60 ]; do \
	  if curl -fsS http://127.0.0.1:8080/health >/dev/null 2>&1 && curl -fsS http://127.0.0.1:5173/ >/dev/null 2>&1; then \
	    echo "UI:      http://127.0.0.1:5173"; \
	    echo "Health:  http://127.0.0.1:8080/health"; \
	    echo "Trading starts disabled. Sign in with the local laboratory account (see lab/README.md)."; \
	    exit 0; \
	  fi; \
	  i=$$((i+1)); sleep 3; \
	done; \
	echo "services did not become ready; run make logs"; exit 1

status:
	$(COMPOSE) ps
	@curl -fsS http://127.0.0.1:8080/health || true
	@echo

logs:
	$(COMPOSE) logs --tail=200 --no-color

reset:
	$(COMPOSE) down -v --timeout 40
	$(COMPOSE) up -d --no-build --pull never

stop:
	$(COMPOSE) stop --timeout 40

verify:
	sh $(ROOT)/scripts/verify.sh

bundle:
	sh $(ROOT)/scripts/bundle.sh

scenario:
	@test -n "$(SCENARIO)" || (echo "usage: make scenario SCENARIO=normal-execution"; exit 1)
	sh $(ROOT)/scripts/scenario.sh $(SCENARIO)

# Stronger technical qualification: reuses trading_system just recipes (not duplicated here).
qualify:
	sh $(ROOT)/scripts/qualify.sh

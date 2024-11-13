MISE=$(HOME)/.local/bin/mise
TUIST=$(MISE) x tuist -- tuist

all: bootstrap project_file

bootstrap:
	command -v $(MISE) >/dev/null 2>&1 || curl https://mise.jdx.dev/install.sh | sh
	$(MISE) install

generate:
	$(TUIST) install
	$(TUIST) generate --no-open

cache:
	$(TUIST) cache --external-only
	$(TUIST) generate --no-open

update:
	$(TUIST) install --update
	$(TUIST) generate --no-open

format:
	$(MISE) x swiftlint -- swiftlint lint --force-exclude --fix .
	$(MISE) x swiftformat -- swiftformat . --config .swiftformat

lint:
	$(MISE) x swiftlint -- swiftlint lint --force-exclude .

test:
	$(TUIST) test

unit_test:
	$(TUIST) test --skip-ui-tests

clean:
	rm -rf build
	$(TUIST) clean

.SILENT: all bootstrap generate cache update format lint test clean

RUSTC ?= rustc
RUSTFLAGS ?= -O -Z debug-info
VERSION=0.1-pre

libyaml_so=build/libyaml-$(VERSION).so
libyaml_files=\
	      $(wildcard src/libyaml/*.rs)

$(libyaml_so): $(libyaml_files)
	mkdir -p build/
	$(RUSTC) $(RUSTFLAGS) src/libyaml/lib.rs --out-dir=build

all: $(libyaml_so) examples

src/libyaml/codegen/codegen: $(wildcard src/libyaml/codegen/*.rs)
	$(RUSTC) $(RUSTFLAGS) $@.rs

src/libyaml/generated/%.rs: src/libyaml/codegen/codegen
	src/libyaml/codegen/codegen $(patsubst src/libyaml/generated/%,%,$@) src/libyaml/generated/

build/%:: src/%.rs $(libyaml_so)
	mkdir -p '$(dir $@)'
	$(RUSTC) $(RUSTFLAGS) $< -o $@ -L build/

examples: $(patsubst src/examples/%.rs,build/examples/%,$(wildcard src/examples/*/*.rs))

build/tests: $(libyaml_files)
	$(RUSTC) $(RUSTFLAGS) --test -o build/tests src/libyaml/lib.rs

build/quicktests: $(libyaml_files)
	$(RUSTC) --test -o build/quicktests src/libyaml/lib.rs

# Can't wait for everything to build, optimised too? OK, you can save some time here.
quickcheck: build/quicktests
	build/quicktests --test

check: all build/tests
	build/tests --test

test:check
tests:check

clean:
	rm -rf src/libyaml/generated/ src/libyaml/codegen/codegen
	rm -rf build/

.PHONY: all examples clean check

RUSTC ?= rustc
RUSTFLAGS ?= -O -Z debug-info
VERSION=0.1-pre
LIB=yaml

$(LIB)_so=build/$(LIB)-$(VERSION).so
$(LIB)_files=\
	      $(wildcard src/*.rs)

$($(LIB)_so): $($(LIB)_files)
	mkdir -p build/
	$(RUSTC) $(RUSTFLAGS) src/lib.rs --out-dir=build

all: $($(LIB)_so) examples

src/codegen/codegen: $(wildcard src/codegen/*.rs)
	$(RUSTC) $(RUSTFLAGS) $@.rs

src/generated/%.rs: src/codegen/codegen
	src/codegen/codegen $(patsubst src/generated/%,%,$@) src/generated/

build/%:: src/%.rs $($(LIB)_so)
	mkdir -p '$(dir $@)'
	$(RUSTC) $(RUSTFLAGS) $< -o $@ -L build/

examples: $(patsubst src/examples/%.rs,build/examples/%,$(wildcard src/examples/*/*.rs))

build/tests: $($(LIB)_files)
	$(RUSTC) $(RUSTFLAGS) --test -o build/tests src/lib.rs

build/quicktests: $($(LIB)_files)
	$(RUSTC) --test -o build/quicktests src/lib.rs

# Can't wait for everything to build, optimised too? OK, you can save some time here.
quickcheck: build/quicktests
	build/quicktests --test

check: all build/tests
	build/tests --test

test:check
tests:check

clean:
	rm -rf src/generated/ src/codegen/codegen
	rm -rf build/

.PHONY: all examples clean check

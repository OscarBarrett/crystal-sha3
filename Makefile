.PHONY: benchmark
benchmark:
	crystal run benchmarks/benchmark_generator.cr; \
	cd benchmarks && crystal build --release -o sha3 generated/benchmark.cr && ./sha3

.PHONY: benchmark-compare
benchmark-compare:
	crystal run benchmarks/benchmark_generator.cr; \
	cd benchmarks; \
	bundle >/dev/null && echo "" && ruby generated/benchmark.rb; \
	crystal build --release -o sha3 generated/benchmark.cr && ./sha3

.PHONY: spec
spec:
	crystal run spec/helpers/kat_spec_generator.cr

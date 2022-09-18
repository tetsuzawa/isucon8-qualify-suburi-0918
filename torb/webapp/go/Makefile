all: build

.PHONY: clean
clean:
	rm -rf torb

deps:
	gb vendor restore

.PHONY: build
build:
	go build -v -o torb src/torb/app.go

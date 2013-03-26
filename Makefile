MOCHA_OPTS=
REPORTER = dot

check: test

build:
	coffee --bare --output . src/*.litcoffee

test:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--reporter $(REPORTER) \
		$(MOCHA_OPTS)

docs:
	docco ./src/*.litcoffee

clean:


.PHONY: test docs clean

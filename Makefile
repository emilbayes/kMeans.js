MOCHA_OPTS=
REPORTER = dot

check: test

test:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--reporter $(REPORTER) \
		$(MOCHA_OPTS)

docs:
	docco ./src/*.litcoffee

clean:


.PHONY: test docs clean

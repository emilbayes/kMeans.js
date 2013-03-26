MOCHA_OPTS=
REPORTER = dot
M = ""

check: test

build:
	npm version build
	coffee --bare --output . src/*.litcoffee

test:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--reporter $(REPORTER) \
		$(MOCHA_OPTS)

docs:
	docco ./src/*.litcoffee

publish:
	git add .
	git commint -m $(M)
	npm publish

patch: 
	npm version patch

publish-patch: publish patch


.PHONY: test docs

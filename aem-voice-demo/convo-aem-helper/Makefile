ci: deps test cov cov-publish install

deps:
	npm install .

test:
	npm run-script test

cov:
	mkdir -p stage
	npm run-script coverage

cov-publish:
	# npm run-script publish-coverage

install:
	npm link

publish:
	npm publish

.PHONY: ci deps test cov cov-publish install publish

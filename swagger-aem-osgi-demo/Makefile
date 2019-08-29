ci: clean deps lint package

clean:
	rm -rf Gemfile.lock bin/ pkg/ stage/ modules/ test/ vendor/

deps:
	gem install bundler --version=1.17.3
	bundle install --binstubs
	bundle exec r10k puppetfile install --verbose --moduledir modules
	mkdir -p stage/

.PHONY: ci clean deps lint package release


demo: deps

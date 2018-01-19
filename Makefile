.PHONY: docs

clean:
	rm -rf Bluebird.xcodeproj/xcuserdata
	rm -rf Bluebird.xcodeproj/project.xcworkspace/xcuserdata

deps:
	swift build
	swift package generate-xcodeproj

docs:
	jazzy \
		--clean \
		--author "Andrew Barba" \
		--author_url https://abarba.me \
		--github_url https://github.com/AndrewBarba/Bluebird.swift \
		--xcodebuild-arguments -scheme,Bluebird-Package \
		--module Bluebird \
		--output docs

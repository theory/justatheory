SITE=justatheory.com
BUCKET=${SITE}
BUILD_DIR=public
CLOUDFRONT_DISTID=E1X44SJ45FTNGI
HUGO=bin/hugo

# Work around https://github.com/aws/aws-cli/issues/5234.
export AWS_REGION=us-west-1

.DEFAULT_GOAL := default

${BUILD_DIR}:
	${HUGO}

default: ${BUILD_DIR}

publish: ${BUILD_DIR}
	./bin/publish ${BUILD_DIR} ${BUCKET} ${CLOUDFRONT_DISTID}

clean:
	rm -rf ${BUILD_DIR}

preview:
	${HUGO} server -D --bind 0.0.0.0

server: preview

image-scan: ${BUILD_DIR}
	htmltest -c .htmltest/images.yml

link-scan: ${BUILD_DIR}
	htmltest -c .htmltest/links.yml

# Matches any target and returns all args. https://stackoverflow.com/a/32490846/79202
%:
	@:

# Filters out the args returned by the % target and strips out the leading content/.
post:
	${HUGO} new -k post $(patsubst content/%,%,$(filter-out $@,$(MAKECMDGOALS)))

photo:
	${HUGO} new -k photo $(patsubst content/%,%,$(filter-out $@,$(MAKECMDGOALS)))

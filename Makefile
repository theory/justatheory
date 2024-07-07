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
	${HUGO} server -DF --bind 0.0.0.0

server: preview

# scan targets require htmltest:
# go install github.com/wjdp/htmltest@latest
image-scan: ${BUILD_DIR}
	htmltest -c .htmltest/images.yml

link-scan: ${BUILD_DIR}
	htmltest -c .htmltest/links.yml

all-links-scan: ${BUILD_DIR}
	htmltest -c .htmltest/all-links.yml

# Matches any target and returns all args. https://stackoverflow.com/a/32490846/79202
%:
	@:

# Filters out the args returned by the % target and strips out the leading content/.
post:
	${HUGO} new -k post $(patsubst content/%,%,$(filter-out $@,$(MAKECMDGOALS)))

photo:
	${HUGO} new -k photo $(patsubst content/%,%,$(filter-out $@,$(MAKECMDGOALS)))

themes/justatheory/static/fonts/fa-*: themes/justatheory/bin/fa-subset.js
	# npm install --save-dev fontawesome-subset @fortawesome/fontawesome-free
	node themes/justatheory/bin/fa-subset.js
	mv fa-regular-400.woff  themes/justatheory/static/fonts/fa-reg.woff
	mv fa-regular-400.woff2 themes/justatheory/static/fonts/fa-reg.woff2
	mv fa-solid-900.woff    themes/justatheory/static/fonts/fa-solid.woff
	mv fa-solid-900.woff2   themes/justatheory/static/fonts/fa-solid.woff2
	mv fa-brands-400.woff   themes/justatheory/static/fonts/fa-brands.woff
	mv fa-brands-400.woff2  themes/justatheory/static/fonts/fa-brands.woff2

# Re-generate the font-awesome fonts. Edit themes/justatheory/bin/fa-subset.js
# to add or remove icons.
font-awesome: themes/justatheory/static/fonts/fa-*

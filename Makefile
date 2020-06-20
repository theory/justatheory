SITE=justatheory.com
BUCKET=${SITE}
BUILD_DIR=public
CLOUDFRONT_DISTID=E1X44SJ45FTNGI
HUGO=hugo

# Work around https://github.com/aws/aws-cli/issues/5234.
export AWS_REGION=us-west-1

.DEFAULT_GOAL := default

${BUILD_DIR}:
	${HUGO}

default: ${BUILD_DIR}

publish:
	${HUGO}
# Can't easily map content types, so sync HTML, XML, and Text first, then everything else.
	aws s3 sync --acl public-read --sse --exclude "*" --include "*.html" --content-type "text/html; charset=utf-8" --metadata-directive=REPLACE --delete ${BUILD_DIR} s3://${BUCKET}
	aws s3 sync --acl public-read --sse --exclude "*" --include "*.xml"  --content-type "application/atom+xml; charset=utf-8" --metadata-directive=REPLACE ${BUILD_DIR} s3://${BUCKET}
	aws s3 sync --acl public-read --sse --exclude "*" --include "*.txt"  --include "*.text"  --content-type "text/plain; charset=utf-8" --metadata-directive=REPLACE ${BUILD_DIR} s3://${BUCKET}
	aws s3 sync --acl public-read --sse --include "*" --exclude "*.html" --exclude "*.xml" --exclude "*.txt" --exclude "*.text" ${BUILD_DIR} s3://${BUCKET}
	aws configure set preview.cloudfront true
	aws cloudfront create-invalidation --distribution-id ${CLOUDFRONT_DISTID} --paths '/*'

clean:
	rm -rf ${BUILD_DIR}

preview:
	${HUGO} server -D --bind 0.0.0.0

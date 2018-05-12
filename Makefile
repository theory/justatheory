SITE=justatheory.com
BUCKET=${SITE}
BUILD_DIR=public
CLOUDFRONT_DISTID=E1X44SJ45FTNGI

.DEFAULT_GOAL := default

${BUILD_DIR}:
	hugo

default: ${BUILD_DIR}

deploy: ${BUILD_DIR}
	aws s3 sync --acl public-read --sse --delete ${BUILD_DIR} s3://${BUCKET}
	aws configure set preview.cloudfront true
	aws cloudfront create-invalidation --distribution-id ${CLOUDFRONT_DISTID} --paths '/*'

clean:
	rm -rf ${BUILD_DIR}

server:
	hugo server -D --bind 0.0.0.0

build: prepare_image
	docker run -v $(PWD):/opt/build --rm -it build-babynames:latest /opt/build/bin/build.sh

prepare_image:
	docker build -t=build-babynames:latest .

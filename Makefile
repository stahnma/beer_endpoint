

image:
	docker build --rm -t centos/beer_endpoint .


run:
	docker run -d -e "GOOGLE_DRIVE_PASSWORD=$(GOOGLE_DRIVE_PASSWORD)" -e "GOOGLE_DRIVE_USERNAME=$(GOOGLE_DRIVE_USERNAME)" --restart=on-failure:10  --name beer_endpoint -p 8334:8334  centos/beer_endpoint

clean:
	docker stop beer_endpoint || true
	docker rm beer_endpoint || true

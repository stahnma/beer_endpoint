

image:
	docker build --rm -t centos/beer_endpoint .


run:
	docker run -d --restart=on-failure:10  --name beer_endpoint -p 8334:8334  centos/beer_endpoint

clean:
	docker stop beer_endpoint || true
	docker rm beer_endpoint || true

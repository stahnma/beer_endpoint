
image:
	docker build --rm -t ruby/beer_endpoint .
run:
	docker run -d --restart=on-failure:10 --name beer_endpoint -p 8334:8334 -v $(shell pwd):/app ruby/beer_endpoint

run_dev:
	docker run -d --restart=on-failure:10 --name beer_endpoint -p 8334:8334 -v $(shell pwd):/app ruby/beer_endpoint shotgun --host 0.0.0.0 --port 8334 /app/app.rb

clean:
	docker stop beer_endpoint || true
	docker rm beer_endpoint || true

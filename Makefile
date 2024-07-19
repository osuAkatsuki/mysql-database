build:
	docker build -t mysql-database:latest .

run:
	docker run --network=host --env-file=.env -it mysql-database:latest

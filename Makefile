HEY ?= "$(HOME)"

hello:
	ls
	echo $(HEY)
up:
	docker-compose up --build

detached:
	docker-compose up --build -d


down:
	docker-compose down

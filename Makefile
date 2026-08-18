DATA_PATH  = /home/$(USER)/data
FILE       = ./srcs/docker-compose.yml

all: up

up:
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress
	mkdir -p $(DATA_PATH)/kuma
	docker compose -f $(FILE) up

build:
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress
	mkdir -p $(DATA_PATH)/kuma
	docker compose -f $(FILE) build --no-cache

down:
	docker compose -f $(FILE) down

clean:
	docker compose -f $(FILE) down -v
	sudo rm -rf $(DATA_PATH)
	@echo "All data containers and persistent data erased!"

fclean: clean
	docker system prune -a --volumes -f
	@echo "Docker environment completely wiped clean!"

re: fclean up


ps:
	docker compose -f $(FILE) ps

logs:
	docker compose -f $(FILE) logs

exec_mariadb:
	docker compose -f $(FILE) exec -it mariadb sh

exec_nginx:
	docker compose -f $(FILE) exec -it nginx sh

exec_wordpress:
	docker compose -f $(FILE) exec -it wordpress sh

exec_redis:
	docker compose -f $(FILE) exec -it redis redis-cli monitor

.PHONY: all up build down clean fclean re ps logs exec_mariadb exec_nginx exec_wordpress exec_redis

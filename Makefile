DATA_PATH = /home/ale/data
FILE      = ./srcs/docker-compose.yml

all: up

up:
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress
	docker compose -f $(FILE) up -d

build:
	mkdir -p $(DATA_PATH)/mariadb
	mkdir -p $(DATA_PATH)/wordpress
	docker compose -f $(FILE) up --build -d

down:
	docker compose -f $(FILE) down

clean: down

fclean:
	docker compose -f $(FILE) down -v
	sudo rm -rf $(DATA_PATH)
	@echo "All data containers and persistent data erased!"

re: fclean build

ps:
	docker compose -f $(FILE) ps

exec_mariadb:
	docker compose -f $(FILE) exec mariadb sh

exec_nginx:
	docker compose -f $(FILE) exec nginx sh

exec_wordpress:
	docker compose -f $(FILE) exec wordpress sh

.PHONY: all up build down clean fclean re ps exec_mariadb exec_nginx exec_wordpress

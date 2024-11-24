# Variables
IMAGE_NAME = flask-app
DOCKER_ID_USER = ollyvern
PORT = 5001

# Show Docker information
image_show:
	@echo "Showing Docker images..."
	docker images

container_show:
	@echo "Showing running Docker containers..."
	docker ps

# Install dependencies locally
install:
	@echo "Installing Python dependencies..."
	python -m pip install --upgrade pip
	python -m pip install -r requirements.txt

# Run the Flask app locally
run:
	@echo "Running the Flask app locally..."
	python app.py

# Docker Hub authentication
login:
	@echo "Logging in to Docker Hub..."
	@if [ -f .env ]; then \
		. .env && echo "$$DOCKER_TOKEN" | docker login -u $(DOCKER_ID_USER) --password-stdin; \
	else \
		echo "Error: .env file not found or DOCKER_TOKEN not set. Please configure it."; \
		exit 1; \
	fi

# Build and push the Docker image
build: login
	@echo "Building Docker image..."
	docker build -t $(IMAGE_NAME) .
	@echo "Tagging Docker image..."
	docker tag $(IMAGE_NAME) $(DOCKER_ID_USER)/$(IMAGE_NAME):latest
	@echo "Pushing Docker image to Docker Hub..."
	docker push $(DOCKER_ID_USER)/$(IMAGE_NAME):latest

# Run the Docker container
docker-run:
	@echo "Stopping any containers using port $(PORT)..."
	-docker stop $$(docker ps -q --filter "publish=$(PORT)")
	@echo "Removing any stopped containers..."
	-docker rm $$(docker ps -q --filter "publish=$(PORT)")
	@echo "Starting a new Docker container..."
	docker run -d -p $(PORT):5000 --name $(IMAGE_NAME)-container $(IMAGE_NAME)

# Stop all running containers
stop:
	@echo "Stopping all running containers..."
	-docker stop $$(docker ps -q)

# Clean up containers and images
clean:
	@echo "Stopping containers..."
	-docker stop $$(docker ps -a -q --filter ancestor=$(IMAGE_NAME))
	@echo "Removing containers..."
	-docker rm -f $$(docker ps -a -q --filter ancestor=$(IMAGE_NAME))
	@echo "Removing image..."
	-docker rmi -f $(IMAGE_NAME)
	@echo "Clean complete."

# Check if the app's port is in use
check-port:
	@echo "Checking if port $(PORT) is in use..."
	-docker ps --filter "publish=$(PORT)"

# Show logs for the container
logs:
	@echo "Showing logs for the container..."
	docker logs $$(docker ps -q --filter ancestor=$(IMAGE_NAME))

# Combined development workflow
dev: build docker-run

.PHONY: image_show container_show install run login build docker-run stop clean check-port logs dev

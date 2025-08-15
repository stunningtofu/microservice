# Create network
docker network create todo-network

# Database
docker run -d \
  --name db \
  --network todo-network \
  --env-file ./env/db.env \
  -v mysql_data:/var/lib/mysql \
  --health-cmd="mysqladmin ping -h 127.0.0.1 -u root -p$${MYSQL_ROOT_PASSWORD}" \
  --health-interval=5s \
  --health-timeout=3s \
  --health-retries=30 \
  mysql:8.0

# Todo Service
docker run -d \
  --name todo-service \
  --network todo-network \
  --env-file ./services/todo-service/app.env \
  $(docker build -q ./services/todo-service)

# Users Service  
docker run -d \
  --name users-service \
  --network todo-network \
  --env-file ./services/users-service/app.env \
  $(docker build -q ./services/users-service)

# Kong Gateway
docker run -d \
  --name kong \
  --network todo-network \
  --env-file ./gateway/kong.env \
  -v ./gateway/kong.yml:/usr/local/kong/declarative/kong.yml:ro \
  -p 8000:8000 \
  kong:3.6

# Frontend
docker run -d \
  --name frontend \
  --network todo-network \
  --env-file ./frontend/app.env \
  -p 5173:8080 \
  $(docker build -q ./frontend)


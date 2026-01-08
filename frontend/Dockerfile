# 1단계: React 빌드
FROM node:18 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build

# 2단계: Nginx로 서빙
FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
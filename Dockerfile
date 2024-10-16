# Fetch data from sonarr and tautulli
FROM python:3.10.12 as fetch-data

COPY requirements.txt .
COPY fetch_api.py .
RUN pip install -r requirements.txt
RUN python3 fetch_api.py

# Build static site
FROM node:20.18.0 as build

# Fill these in with appropriate values
ENV VITE_SONARR_URL=""
ENV VITE_TAUTULLI_URL=""
ENV VITE_SONARR_API_KEY=""
ENV VITE_TAUTULLI_API_KEY=""

COPY --from=fetch-data /public/ ./public
COPY --from=fetech-data /sonarr-cal.json ./
COPY --from=fetech-data /tautulli-watched.json ./
COPY package*.json .
COPY *.config.js .
COPY index.html .
RUN npm ci

COPY src src
RUN npm run build

# Serve static site from nginx
FROM nginx:stable-alpine

COPY --from=build /dist/ /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
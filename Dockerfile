# Simple static web server using nginx
FROM nginx:alpine
COPY ./app /usr/share/nginx/html
# expose port 80 (nginx default)
EXPOSE 80
HEALTHCHECK --start-period=5s --interval=10s --timeout=3s CMD wget -qO- http://localhost || exit 1


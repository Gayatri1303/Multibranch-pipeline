FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY react_app.conf /etc/nginx/conf.d/default.conf
COPY /build /usr/share/nginx/html
CMD ["nginx", "-g", "daemon off;"]


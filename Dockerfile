FROM node:18.20-alpine AS build-stage

WORKDIR /var/www

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build

#EXPOSE 5173
#RUN npm run build
#CMD [ "npm", "run", "dev", "--", "--host" ]


#Prod

FROM nginx:alpine
COPY --from=build-stage /var/www/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

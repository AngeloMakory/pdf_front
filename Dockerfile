FROM node:18.20-alpine

WORKDIR /var/www

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 5173
RUN npm run build
CMD [ "npm", "run", "dev", "--", "--host" ]


#Prod

FROM nginx:alpine
COPY --from=build-stage /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

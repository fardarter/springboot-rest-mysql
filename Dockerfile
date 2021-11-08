FROM node:16
WORKDIR /repos
RUN git clone https://github.com/AnatolyUss/nmig.git
WORKDIR /repos/nmig
RUN git checkout v5.5.0
RUN npm install && npm run build 
COPY nmig/config.json config/config.json
CMD ["npm", "start"]
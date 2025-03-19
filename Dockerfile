# Utilise l'image officielle Node.js 18
FROM node:18

# Définir le répertoire de travail dans le container
WORKDIR /usr/src/app

# Copier les fichiers du projet dans le container
COPY . .

# Installer les dépendances
RUN npm install

# Exposer le port 3000
EXPOSE 3000

# Lancer l'application
CMD ["npm", "start"]

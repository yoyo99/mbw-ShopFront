# Étape 1 : Build avec Node.js 18 (LTS)
FROM node:20-alpine AS builder

WORKDIR /app

# Copie les fichiers de config et lock pour optimiser le cache
COPY package.json yarn.lock* ./
COPY next.config.js ./

# Installe les dépendances (avec --frozen-lockfile pour éviter les mises à jour involontaires)
RUN yarn install --frozen-lockfile

# Copie le reste du code
COPY . .

# Build l'application
RUN yarn build

# Étape 2 : Image légère pour la production
FROM node:20-alpine AS runner

WORKDIR /app

# Copie uniquement les fichiers nécessaires
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/yarn.lock* ./
COPY --from=builder /app/next.config.js ./

# Installe uniquement les dépendances de production
RUN yarn install --production

# Variable pour désactiver la validation d'environnement (évite les erreurs)
ENV SKIP_ENV_VALIDATION=true

# Lance Next.js en mode production
CMD ["yarn", "start"]

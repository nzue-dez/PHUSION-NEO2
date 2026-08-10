# Image R officielle — même version que ton projet
FROM rocker/tidyverse:4.5.2

# Installer les dépendances système nécessaires
RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libharfbuzz-dev \
    libfribidi-dev \
    libfreetype6-dev \
    libpng-dev \
    libtiff5-dev \
    libjpeg-dev \
    libcairo2-dev \
    libnode-dev

# Copier le projet dans le container
COPY . /home/proj_exercise
WORKDIR /home/proj_exercise

# Dire à renv où stocker les packages
ENV RENV_PATHS_LIBRARY=renv/library

# Installer renv
RUN R -e "install.packages('renv', repos='https://cloud.r-project.org')"
RUN R -e "renv::restore(prompt = FALSE)"

# Créer les dossiers de sortie
RUN mkdir -p results figures

# Lancer l'analyse principale
CMD ["Rscript", "analyse.R"]
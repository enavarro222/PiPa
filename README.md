rPyBoard
=========

Dashboard pour rPy (ou autre)

Site web a ouvrir en full screen, le serveur push les update.

Affichage possible:
* valeur
* unité
* date/heure
* image
* courbe
* jauge (min, max, value, unit)

config:
* config coté serveur des sources existantes
* config coté client des widget sur quelles sources

API:
* GET /sources: découverte de toute les sources dispo
* GET /sources/<source_name>/connect: register socketio notification pour cette source
* GET /sources/<source_name>: recupération JSON des data de cette source



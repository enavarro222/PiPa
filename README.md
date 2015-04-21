PiPa (Raspberry Pi Panel)
=========================

Dashboard pour rPy (ou autre)

La config du dashboard se fait direct dans le source JS.

Site web a ouvrir en full screen, le serveur push les updates des sources de données (brut)

Widgets type:
* heure et date
* numéro de semaine
* generic value (icone, label, value/unit)
* temperature/humidité d'une pièce/exterieur
* liste d'info/event (avec date a chaque fois, éventuellement removable)
    * passage facteur
    * batterie faible (toutes les heures quand c'est le cas)
    * pic de conso


Affichage:
* doit feeter sur une page sans scroll

config:
* config coté serveur des sources existantes
* config coté client des widget sur quelles sources

API:
* GET /sources: découverte de toute les sources dispo
* GET /sources/<source_name>/connect: register socketio notification pour cette source
* GET /sources/<source_name>: recupération JSON des data de cette source


Hardware
========

(TODO)

Install
=======

(TODO)

Configure
=========

* data sources are configured in app.py
* dashboards are defined on src_ls/app.ls

TODO
====

* translate README all in english
* add installation procedure
* add some screenshot



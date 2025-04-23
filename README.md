Trell Tech

Une application mobile Flutter connectée à l’API Trello, permettant la gestion complète de vos tableaux, cartes et espaces de travail. Ce projet a été développé en Dart avec le framework Flutter.

Fonctionnalités

Cartes (Cards)

Lecture des cartes d’un tableau
Création de nouvelles cartes
Modification des cartes existantes
Suppression de cartes
Tableaux (Boards)

Liste des tableaux de l’utilisateur
Création de tableaux avec titre et description
Mise à jour des informations du tableau
Suppression d’un tableau
Affichage des tableaux récemment consultés
Espaces de travail (Workspaces)

Affichage des informations de l’espace de travail associé à l’utilisateur

Changement de la visibilité (public/privé)

Affichés les tableaux récents

Listes (list)

-Afficher les 3 listes

Technologies utilisées

Flutter (SDK Dart)
API Trello (via https://api.trello.com)
Packages Flutter :
http – pour les appels réseau
go_router – pour la navigation
flutter_dotenv – pour la gestion des clés API
shared_preferences – pour stocker les tableaux récents
Autres utilitaires (ex. : provider, etc.)
⚙️ Configuration

Cloner le projet

git clone git@github.com:EpitechMscProPromo2027/T-DEV-600-PAR_13.git
cd trello_application
##Intsallations des dépendances flutter pub get

##Démarrer le projet flutter run

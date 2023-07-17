# DNSContract et MissionContract

Les contrats DNSContract et MissionContract sont des contrats Solidity conçus pour travailler ensemble afin de faciliter la gestion des tâches et des permissions liées à une entreprise.

## DNSContract

Le DNSContract permet la gestion d'autres contrats sous des noms uniques et permet de récupérer les adresses de contrats par leur nom unique. Il fonctionne en conjonction avec un contrat TokenJournalized qui gère les autorisations administrateur.

## MissionContract

Le MissionContract est conçu pour gérer et attribuer des missions aux employés au sein d'une entreprise. Les missions sont créées par les administrateurs du contrat et peuvent être validées et confirmées pour chaque employé.

## Prérequis

- Solidity ^0.8.0
- Une instance déployée des contrats TokenJournalized, DNSContract et MissionContract.

## Commencer

Pour DNSContract, vous devez l'initialiser avec l'adresse d'une instance déjà déployée de TokenJournalized.

```javascript
constructor(address contractAddress)
```

Pour MissionContract, vous devez l'initialiser avec l'adresse d'une instance déjà déployée de TokenJournalized et DNSContract.

```javascript
constructor(address dsnAddress, address token)
```

## Fonctionnalités

### DNSContract

- Ajouter une adresse de contrat
- Récupérer une adresse de contrat par son nom

### MissionContract

- Ajouter un administrateur de contrat
- Supprimer un administrateur de contrat
- Créer une mission booléenne
- Récupérer une mission booléenne par son nom
- Valider une mission booléenne pour un employé
- Valider plusieurs missions booléennes pour plusieurs employés
- Confirmer une mission pour un employé
- Supprimer une mission booléenne
- Marquer une mission booléenne comme terminée
- Récupérer les missions validées d'un employé
- Créer plusieurs missions en une seule fois
- Récupérer l'état des missions d'un employé
- Vérifier si une mission est validée par un employé
- Vérifier si une mission est validée et confirmée par un employé

## Remarque

Pour plus de détails sur chaque fonction, veuillez consulter les commentaires dans le code du contrat.

# 🚀 CI/CD Pipeline avec GitHub Actions, Docker et Kubernetes (kind)

Ce projet illustre la mise en place d'un pipeline CI/CD complet, intégrant la construction d'images Docker, le déploiement sur un cluster Kubernetes (via kind) et l'automatisation avec GitHub Actions. C'est la première fois que j'implémente un déploiement réussi sur un cluster kind, ce qui représente une étape marquante dans mes expérimentations CI/CD !

---

## 📋 Contexte & Objectifs

L'objectif de ce TP était de :
- Gérer le code source avec Git (local et distant).
- Construire et déployer une application conteneurisée en utilisant Docker.
- Automatiser l'intégration continue et le déploiement continu (CI/CD) avec GitHub Actions.
- Déployer l'application sur un cluster Kubernetes local créé avec [kind](https://kind.sigs.k8s.io/).
- Configurer un service **NodePort** pour accéder à l'application en local.

---

## 🛠️ Ce qui a été Réalisé

1. **Gestion du Code avec Git**  
   - Initialisation du dépôt local et gestion des commits.  
   - Liaison avec le dépôt distant et synchronisation des modifications.

2. **Pipeline CI avec GitHub Actions**  
   - Création du workflow dans `.github/workflows/ci.yml` pour :  
     - Checkout du code source.  
     - Construction de l'image Docker avec la commande :  
       ```bash
       docker build -t yourusername/hello-world-node:${{ github.sha }} .
       ```  
       > La variable `${{ github.sha }}` est automatiquement fournie par GitHub Actions.  
     - Connexion à Docker Hub et push de l'image.

3. **Déploiement sur Kubernetes (kind)**  
   - Utilisation d'un fichier de déploiement (`deployment.yml`) et d'un fichier de service (`service.yml`).  
   - Initialement, le service était de type **LoadBalancer** mais j'ai rencontré des problèmes d'accès sur l'action de déploiement dans GitHub Actions.  
   - **Solution adoptée :**  
     J'ai opté pour la **kind card** en changeant le type de service en **NodePort** afin de pouvoir accéder à l'application via `localhost:30080`.  
   - Commandes exécutées :  
     ```bash
     kubectl apply -f deployment.yml
     kubectl apply -f service.yml
     ```
   - Vérification avec :  
     ```bash
     kubectl get services
     kubectl get pods
     ```

4. **Runners GitHub Actions et Problèmes de Déploiement**  
   - Un problème a été rencontré dans la partie **deploy** du workflow, déconnectant le dépôt local du dépôt distant.  
   - Après investigation et ajustements (notamment dans la gestion des secrets et du kubeconfig), le pipeline de déploiement a été rétabli avec succès.

---

## 🔍 Problèmes Rencontrés & Pistes de Résolution

- **Aucun Pod Affiché :**  
  - **Symptôme :** `kubectl get pods` retourne _"No resources found in default namespace."_  
  - **Analyse :** Le déploiement n'a peut-être pas été appliqué correctement ou se trouve dans un autre namespace.  
  - **Solution :**  
    - S'assurer d'avoir appliqué le fichier `deployment.yml` :  
      ```bash
      kubectl apply -f deployment.yml
      ```  
    - Vérifier le namespace avec :  
      ```bash
      kubectl get pods --all-namespaces
      ```

- **Service LoadBalancer et Accès en Local :**  
  - **Symptôme :** Un service de type LoadBalancer affiche `<pending>` pour l'EXTERNAL-IP sur kind.  
  - **Solution Adoptée :**  
    - Modification du service en **NodePort** pour accéder directement via `localhost:30080`.
  
- **Timeout avec Port-forwarding :**  
  - **Symptôme :** La commande `kubectl port-forward` échoue avec l'erreur _"timed out waiting for the condition"_.  
  - **Solution Adoptée :**  
    - Le changement vers un service NodePort permet d'éviter ce problème, rendant le port-forwarding inutile.

- **Problème d'Accès sur l'Action Deploy dans GitHub Actions :**  
  - J'ai rencontré des difficultés spécifiques lors de l'exécution de l'action de déploiement dans GitHub Actions, ce qui a temporairement déconnecté le dépôt local du dépôt distant.  
  - Après plusieurs ajustements, notamment au niveau des secrets et du fichier kubeconfig, le problème a été résolu.

---

## 💡 Leçons Apprises & Conseils

- **Validation Locale :**  
  Testez toujours vos configurations localement (Docker build, `kubectl apply`) avant de pousser sur GitHub.
  
- **Gestion des Namespaces :**  
  Soyez vigilant quant au namespace utilisé par vos ressources Kubernetes et vérifiez toujours avec `--all-namespaces` si nécessaire.

- **Secrets et Configurations :**  
  La gestion des secrets (comme `DOCKER_USERNAME`, `DOCKER_PASSWORD`, `KUBECONFIG`) est cruciale pour la réussite de vos workflows GitHub Actions.

- **Adoption de kind pour Déploiement :**  
  C'est une première réussie pour moi avec un déploiement sur un cluster kind, démontrant que même avec des contraintes (ex. LoadBalancer non supporté), des solutions comme le NodePort permettent d'adapter le déploiement à l'environnement local.

---

## 📚 Ressources Utiles

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kind Documentation](https://kind.sigs.k8s.io/)
- [MetalLB (pour LoadBalancer sur kind)](https://metallb.universe.tf/)




# TP CI/CD

# 🚀 CI/CD Pipeline avec GitHub Actions, Docker et Kubernetes (kind)

Ce projet est une démonstration de la mise en place d'un pipeline CI/CD complet, intégrant la construction d'images Docker, le déploiement sur un cluster Kubernetes (via kind) et l'automatisation avec GitHub Actions.

---

## 📋 Contexte & Objectifs

L'objectif de ce TP était de :
- Gérer le code source avec Git (local et distant).
- Construire et déployer une application conteneurisée en utilisant Docker.
- Automatiser le processus d'intégration continue et de déploiement continu (CI/CD) grâce à GitHub Actions.
- Déployer l'application sur un cluster Kubernetes local créé avec [kind](https://kind.sigs.k8s.io/).
- Configurer un service NodePort pour accéder à l'application en local.

---

## 🛠️ Ce qui a été réalisé

1. **Gestion du Code avec Git**
   - Initialisation du dépôt local (`git init`, `git add .`, `git commit -m "Initial commit"`).
   - Création et liaison du dépôt distant.
   - Mise à jour et push des modifications.

2. **Pipeline CI avec GitHub Actions**
   - Création d'un workflow CI dans le fichier `.github/workflows/ci.yml` qui :
     - Checkout le code source.
     - Construit l'image Docker avec la commande :
       ```bash
       docker build -t yourusername/hello-world-node:${{ github.sha }} .
       ```
     - Se connecte à Docker Hub et pousse l'image.
   - **Note :** La variable `${{ github.sha }}` est injectée automatiquement par GitHub Actions.

3. **Déploiement sur Kubernetes**
   - Utilisation d'un fichier de déploiement (`deployment.yml`) et d'un fichier de service (`service.yml`).
   - Pour contourner la limitation de kind (qui ne supporte pas nativement les LoadBalancer), le service a été modifié en type **NodePort** pour accéder à l'application sur le port `30080`.
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

4. **Problèmes rencontrés :**
   - **Aucun pod affiché :**  
     Après avoir exécuté `kubectl get pods`, le message **"No resources found in default namespace."** a été affiché.  
     **Analyse :**
     - Cela peut signifier que le fichier de déploiement (`deployment.yml`) n’a pas été appliqué correctement.
     - Ou que les ressources ont été déployées dans un autre namespace.  
     **Vérifications à effectuer :**
     - S’assurer d’avoir appliqué les fichiers YAML via `kubectl apply -f deployment.yml`.
     - Vérifier le namespace courant avec `kubectl config current-context` et tester avec `kubectl get pods --all-namespaces`.
   
   - **Service LoadBalancer en mode kind :**  
     Le service était initialement de type **LoadBalancer**, ce qui provoquait l'affichage d'une IP externe `<pending>` puisque kind ne supporte pas ce type.  
     **Solution adoptée :**  
     - Changer le type de service en **NodePort** pour accéder à l'application via `http://localhost:30080`.

   - **Port-forward timeout :**  
     La commande `kubectl port-forward service/hello-world-node-service 8080:80` renvoyait une erreur de type `timed out waiting for the condition`.  
     **Analyse :**
     - Cela est lié à l’inadéquation du type de service (LoadBalancer) et à l’absence de pods associés.
     - En passant à un service NodePort, l'accès se fait directement via le port défini sans nécessité de port-forwarding.

5. **Impact sur les Runners GitHub Actions**
   - Au cours du TP, une configuration avec les runners de GitHub Actions a déconnecté le dépôt local du dépôt distant.
   - Cela a nécessité une reconfiguration ou une re-synchronisation du dépôt Git afin de rétablir la communication entre les environnements local et distant.

---

## 📌 Points Clés et Pistes de Résolution

- **Build & Deploy :**
  - L'image Docker est construite et poussée avec succès.
  - Le déploiement sur Kubernetes se fait via les fichiers YAML et via une étape de déploiement dans GitHub Actions.

- **Vérification et Débogage :**
  - Vérifiez toujours que le bon namespace est utilisé.
  - En cas de problèmes de pods non visibles, utilisez :
    ```bash
    kubectl get pods --all-namespaces
    kubectl describe deployment <nom-du-deployment>
    kubectl get events
    ```
  - Pour accéder à l’application, privilégiez l’usage d’un service NodePort en environnement kind.

- **GitHub Actions & Secrets :**
  - Assurez-vous que tous les secrets (comme `DOCKER_USERNAME`, `DOCKER_PASSWORD`, `KUBECONFIG`) sont correctement configurés dans le dépôt distant sur GitHub.

---

## 🔍 Conclusion

Ce TP a permis d'explorer les différentes étapes d'un pipeline CI/CD, de la gestion du code source jusqu'au déploiement sur un cluster Kubernetes local avec kind. Les principales difficultés ont concerné la configuration des services sur kind et la gestion des namespaces, ainsi que des ajustements nécessaires lors de l'utilisation des runners GitHub Actions.

Ce projet sert de base pour déployer et gérer vos futures applications conteneurisées en production, et illustre l'importance de bien maîtriser les outils d'intégration et de déploiement continus.

---

## 📚 Ressources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Documentation](https://docs.docker.com/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kind Documentation](https://kind.sigs.k8s.io/)
- [MetalLB pour simuler LoadBalancer sur kind](https://metallb.universe.tf/)

---

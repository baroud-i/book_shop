# Book Shop Multi-Branch CI/CD Architecture

This project implements an automated, artifact-first multi-branch CI/CD infrastructure deployed on a single AWS EC2 instance.

## 👥 Project Metadata
* **Group Size:** Individual Project
* **Student Name:** Omar
* **University:** Princess Sumaya University for Technology (PSUT)

---

## 🌿 Branching & Deployment Coexistence Strategy
The project utilizes three isolated environments running concurrently on a single EC2 instance (`3.65.60.1`). Each environment is isolated via Docker Compose project naming flags (`-p`) and maps onto separate host ports to prevent port conflicts:

| Branch | Pipeline Type | Deployment Directory | Live Access URL |
| :--- | :--- | :--- | :--- |
| `dev` | Artifact-First Pipeline | `~/deployments/dev` | http://3.65.60.1:8080 |
| `test` | Image-First Pipeline | `~/deployments/test` | http://3.65.60.1:8081 |
| `prod` | Promotion/Release Pipeline | `~/deployments/prod` | http://3.65.60.1:80 |

---

## 🛠️ Pipeline Workflows & Mechanics

### 1. Development Pipeline (`dev.yml`) - Artifact-First
* **Trigger:** Pushes to the `dev` branch.
* **Mechanics:** Bundles application source code into a timestamped/short-SHA compressed tarball (`.tar.gz`) after running static file checks. 
* **History Accumulation:** The automated runner commits this compressed asset back into the `artifacts/` folder of the repository, guaranteeing a traceable audit history of stable packages. 
* **Deployment:** Builds a Docker image directly utilizing the compiled artifact asset, pushes it to Docker Hub, and tells the EC2 instance to reload the stack on port `8080`.

### 2. Testing Pipeline (`test.yml`) - Image-First
* **Trigger:** Pushes to the `test` branch (following a clean merge from `dev`).
* **Mechanics:** Follows an automated image-first compilation pathway. It reads the code structure, validates static dependencies, builds a testing image variant, pushes it to Docker Hub, and stands up the testing containers on port `8081`.

### 3. Production Pipeline (`prod.yml`) - Promotion-Only
* **Trigger:** Pushes to the `prod` branch.
* **Mechanics:** Rather than compiling fresh loose code variants, this pipeline enforces stability by parsing the specific deployment version tag defined inside the GitHub Actions repository variable (`IMAGE_VERSION`).
* **Deployment:** Pulls the promoted image and deploys it onto standard HTTP port `80`.

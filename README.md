# Book Shop — Docker Deployment

## Requirements
- Docker (with Docker Compose)

## Setup

1. Clone the repo:
   ```bash
   git clone [https://github.com/ayat93a/book_shop.git](https://github.com/ayat93a/book_shop.git)
   cd book_shop

2. Create your environment file from the template:

cp .env.example .env
## Note: Open .env and fill in your actual passwords.

3. Build and launch the entire system:

docker compose up --build

4. Access the application:

## Open your web browser and go to: http://localhost

5. Create an Admin Account:

## While the containers are running, open a new terminal tab and run:

docker compose exec backend python manage.py createsuperuser

# Oracle / Java / TypeScript Full Stack Homework

A small full-stack application that implements and visualizes tasks 1-3 and includes a short Oracle Forms modernization proposal (task 4).

## Technology stack

- Oracle Database: SQL and PL/SQL package
- Backend: Java 21, Spring Boot, Spring JDBC, Gradle
- Frontend: TypeScript, HTML and CSS (no framework; Angular/Vue was optional)
- Tests: JUnit 5, Mockito, Spring MVC test

## Architecture

```text
Browser (TypeScript)
        |
        | HTTP/JSON
        v
Spring Boot REST API
Controller -> Service -> Repository
        |
        | JDBC / CallableStatement
        v
Oracle Database / PL/SQL
```

The backend uses layered design. Controllers handle HTTP concerns, services contain validation and application logic, and repositories isolate Oracle/JDBC access.

## Important assumptions

1. The age ranges in the assignment overlap at 7 and 18. To make them deterministic, this implementation uses: 0-7, 8-18, 19-39, 40-54 and 55+.
2. Task 2 uses the Bailey–Borwein–Plouffe (BBP) formula supplied in the assignment. Precision is interpreted as the number of iterations.
3. Payments are compared with invoices only when their currency is the same. Currency conversion is outside the supplied requirements.
4. A negative age, non-positive precision, or precision above 1,000 returns HTTP 400.

## Database installation

Run scripts in this order using SQL*Plus, SQLcl, SQL Developer or another Oracle client:

```sql
@database/00_install.sql
```

The script creates tables, sample data and the PL/SQL package.

## Backend configuration

Do not commit real credentials. Set environment variables:

```bash
export DB_URL='jdbc:oracle:thin:@//localhost:1521/FREEPDB1'
export DB_USERNAME='homework'
export DB_PASSWORD='change_me'
```

On Windows PowerShell:

```powershell
$env:DB_URL='jdbc:oracle:thin:@//localhost:1521/FREEPDB1'
$env:DB_USERNAME='homework'
$env:DB_PASSWORD='change_me'
```

## Build and run

Requirements: JDK 21 and Gradle 8.5+.

```bash
cd backend
gradle clean test bootRun
```

Open <http://localhost:8080>.

REST endpoints:

- `GET /api/ages/{age}`
- `POST /api/pi` with JSON `{ "precision": 10000 }`
- `GET /api/invoices/unpaid`

## Frontend development

The compiled JavaScript is already included in `backend/src/main/resources/static/app.js`, so Java/Gradle is enough to run the application. The TypeScript source is in `frontend/src/app.ts`.

To recompile TypeScript:

```bash
cd frontend
npm install
npm run build
```

Then copy `frontend/dist/app.js` to `backend/src/main/resources/static/app.js`.

## Task 4 document

- `docs/oracle-forms-modernization.pdf`

## AI usage

OpenAI ChatGPT:

- propose the initial project structure and layered architecture;
- AI assistance was used to generate the Java/Spring Boot and TypeScript implementation. 
- draft unit tests, documentation and the modernization proposal;
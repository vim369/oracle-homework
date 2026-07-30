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

## Change Log

### 2026-07-30
- Changed age_category table structure
- Added trigger trg_age_category_overlap for overlapping protection
- Changed pi_calculation_step table structure to GLOBAL TEMPORARY TABLE
- Added logger_items table
- Added logging for all functions in package

---

## Testing

The following scenarios were tested.

### 1. Basic functionality

- Age category lookup
- π calculation
- Intermediate calculation steps
- Unpaid invoices JSON generation

```sql
declare
    l_json clob;
begin
    dbms_output.put_line('age 7:  ' || pkg_homework.get_age_description(7));
    dbms_output.put_line('age 18: ' || pkg_homework.get_age_description(18));
    dbms_output.put_line('age 40: ' || pkg_homework.get_age_description(40));
   dbms_output.put_line('Age 1155: ' || pkg_homework.get_age_description(1155));

    dbms_output.put_line('pi/10 iterations: ' || pkg_homework.calculate_pi(10));

    commit;

    for i in (select * from pi_calculation_step order by step_no) loop
        dbms_output.put_line(i.step_no || ' ' || i.term_value);
    end loop;

    l_json := pkg_homework.get_unpaid_invoices;
    dbms_output.put_line(dbms_lob.substr(l_json, 32767, 1));
END;

/*output*/

Age 7:  You are infant
Age 18: You are schoolchild
Age 40: You are in middle-age
Age 1155: You are aged

PI/10 iterations: 3.14159265358979114638877696591034741476
1 3.13333333333333333333333333333333333333
2 .008089133089133089133089133089133089133088
3 .000164923924115100585688820982938629997454
4 .00000506722085385878489326765188834154351396
5 .0000001878929009377200166673850884377200166672
6 .000000007767751215177356813093822637831121394157
7 .000000000344793293050862726359694014680537591588
8 .00000000001609187715553700527429096273205488602519
9 .0000000000007795702954001012279127788239041435972322
10 .0000000000000388711525990975122451889839912550799359

[{"invoiceId":1002,"invoiceDate":"2026-01-11","amount":200,"currency":"EUR","paidAmount":120,"unpaidAmount":80},{"invoiceId":1004,"invoiceDate":"2026-01-13","amount":75,"currency":"EUR","paidAmount":0,"unpaidAmount":75}]

```

### 2. Error handling

The following test intentionally creates overlapping age ranges.
```sql
INSERT INTO age_category(age_from, age_to, description)
VALUES (1, 17, 'You are infants');

ORA-20001: Age ranges must not overlap
ORA-06512: at "VIM.TRG_AGE_CATEGORY_OVERLAP", line 11
ORA-04088: error during execution of trigger 'VIM.TRG_AGE_CATEGORY_OVERLAP'
```

Invalid input
```sql
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        pkg_homework.get_age_description(-1)
    );
END;

ORA-20001: Amžius turi būti teigiamas sveikasis skaičius
ORA-06512: at "VIM.PKG_HOMEWORK", line 113
ORA-06512: at "VIM.PKG_HOMEWORK", line 93
ORA-06512: at line 5
```
Provoking a "character string buffer too small" error
```sql
BEGIN
    DBMS_OUTPUT.PUT_LINE(
        pkg_homework.get_age_description(1)
    );
END;

ORA-06502: PL/SQL: value or conversion error: character string buffer too small
ORA-06512: at "VIM.PKG_HOMEWORK", line 114
ORA-06512: at "VIM.PKG_HOMEWORK", line 97
ORA-06512: at line 5
```

### 3. Logger

Logger entries can be verified with:

```sql
SELECT * FROM logger_items ORDER BY event_date desc;
```

Example output:

| EVENT_DATE | MSG_TYPE | MSG_HEADER | MSG_BODY |
|------------|----------|------------|----------|
2026.07.30 17:50:27 | ERROR | get_age_description | -6502 ORA-06502: PL/SQL: value or conversion error: character string buffer too small
2026.07.30 16:32:50 | ERROR | get_age_description | -20001 ORA-20001: Amžius turi buti teigiamas sveikasis skaicius
2026.07.30 16:03:16 | SUCCESS | get_age_description | You are schoolchild
2026.07.30 16:03:16 | SUCCESS | get_unpaid_invoices | 
2026.07.30 16:03:16 | SUCCESS | calculate_pi | 3.14159265358979114638877696591034741476
2026.07.30 16:03:16 | SUCCESS | get_age_description | You are in middle-age
2026.07.30 16:03:16 | SUCCESS | get_age_description | You are infant
2026.07.30 16:02:48 | SUCCESS | get_age_description | You are schoolchild
2026.07.30 16:02:48 | SUCCESS | get_age_description | You are in middle-age
2026.07.30 16:02:48 | ERROR | get_age_description | -20001 ORA-20001: Amžius turi buti teigiamas sveikasis skaicius"
2026.07.30 16:02:48 | SUCCESS | get_age_description | You are infant
2026.07.30 15:46:11 | SUCCESS | get_unpaid_invoices | 
2026.07.30 15:34:42 | SUCCESS | calculate_pi | 3.14159265358979114638877696591034741476
2026.07.30 15:32:31 | SUCCESS | calculate_pi | 3.14159265358979114638877696591034741476
2026.07.30 15:31:37 | SUCCESS | calculate_pi | 3.14159265358979114638877696591034741476
2026.07.30 15:30:04 | SUCCESS | calculate_pi | 3.14159265358979114638877696591034741476
2026.07.30 15:27:52 | SUCCESS | calculate_pi | 3.14159265358979114638877696591034741476
2026.07.30 15:22:48 | SUCCESS | calculate_pi | 3.13333333333333333333333333333333333333
2026.07.30 15:22:05 | ERROR | GET_AGE_DESCRIPTION | -20001 ORA-20001: Amžius turi buti teigiamas sveikasis skaicius
2026.07.30 15:19:54 | SUCCESS | GET_AGE_DESCRIPTION | You are aged
2026.07.30 15:19:48 | SUCCESS | GET_AGE_DESCRIPTION | You are aged
2026.07.30 15:19:33 | SUCCESS | GET_AGE_DESCRIPTION | You are infant


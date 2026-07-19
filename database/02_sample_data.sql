insert into age_category(age_from, age_to, description) values (0, 7, 'You are infant');
insert into age_category(age_from, age_to, description) values (8, 18, 'You are schoolchild');
insert into age_category(age_from, age_to, description) values (19, 39, 'You are adult');
insert into age_category(age_from, age_to, description) values (40, 54, 'You are in middle-age');
insert into age_category(age_from, age_to, description) values (55, null, 'You are aged');

insert into invoice values (1001, date '2026-01-10', 100.00, 'EUR');
insert into invoice values (1002, date '2026-01-11', 200.00, 'EUR');
insert into invoice values (1003, date '2026-01-12', 150.00, 'USD');
insert into invoice values (1004, date '2026-01-13', 75.00,  'EUR');

insert into payment values (5001, date '2026-01-15', 40.00,  'EUR', 1001);
insert into payment values (5002, date '2026-01-16', 60.00,  'EUR', 1001);
insert into payment values (5003, date '2026-01-16', 120.00, 'EUR', 1002);
insert into payment values (5004, date '2026-01-17', 25.00,  'USD', 1002);
insert into payment values (5005, date '2026-01-18', 160.00, 'USD', 1003);
commit;

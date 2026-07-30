set serveroutput on

declare
    l_json clob;
begin
--insert into age_category(age_from, age_to, description) values (1, 17, 'You are infants'); /*error test*/
--dbms_output.put_line('Age -1: ' || pkg_homework.get_age_description(-1)); /*error test*/
    dbms_output.put_line('Age 7:  ' || pkg_homework.get_age_description(7));
    dbms_output.put_line('Age 18: ' || pkg_homework.get_age_description(18));
    dbms_output.put_line('Age 40: ' || pkg_homework.get_age_description(40));

    dbms_output.put_line('PI/10 iterations: ' || pkg_homework.calculate_pi(10));
    commit;
    for i in (select * from pi_calculation_step order by step_no) loop
        dbms_output.put_line (i.step_no || ' ' ||  i.term_value);
    end loop;

    l_json := pkg_homework.get_unpaid_invoices;
    dbms_output.put_line(dbms_lob.substr(l_json, 32767, 1));
end;
/
select * from logger_items

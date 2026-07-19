set serveroutput on

declare
    l_json clob;
begin
    dbms_output.put_line('Age 7:  ' || pkg_homework.get_age_description(7));
    dbms_output.put_line('Age 18: ' || pkg_homework.get_age_description(18));
    dbms_output.put_line('Age 40: ' || pkg_homework.get_age_description(40));
    dbms_output.put_line('PI/10 iterations: ' || pkg_homework.calculate_pi(10));

    l_json := pkg_homework.get_unpaid_invoices;
    dbms_output.put_line(dbms_lob.substr(l_json, 32767, 1));
end;
/

select * from pi_calculation_step order by step_no;

CREATE OR REPLACE PACKAGE pkg_homework as

    /* Amžiaus grupė */
    FUNCTION get_age_description(
        p_age in number
    ) return varchar2;

    /* PI skaičiavimas */
    FUNCTION calculate_pi(
        p_precision in pls_integer
    ) return number;

    /* Neapmokėtos sąskaitos */
    FUNCTION get_unpaid_invoices
        return clob;

end pkg_homework;
/

CREATE OR REPLACE PACKAGE BODY pkg_homework as

    /* Amžiaus grupė */
    FUNCTION get_age_description(
        p_age in number
    ) return varchar2
    is
        l_description age_category.description%type;
    begin
        if p_age is null or p_age < 0 or p_age != trunc(p_age) then
            raise_application_error(-20001, 'Amžius turi būti neneigiamas sveikasis skaičius');
        end if;

        select description
          into l_description
          from age_category
         where p_age >= age_from
           and (age_to is null or p_age <= age_to);

        return l_description;
    exception
        when no_data_found then
            raise_application_error(-20002, 'Amžiui ' || p_age || ' grupė nerasta');
        when too_many_rows then
            raise_application_error(-20003, 'Amžiui ' || p_age || ' rasta daugiau nei viena grupė');
    end get_age_description;

    /* PI skaičiavimas */
    FUNCTION calculate_pi(
        p_precision in pls_integer
    ) return number
    is
        l_pi    number := 0;
        l_value number;
    begin
        if p_precision is null or p_precision < 1 or p_precision > 1000 then
            raise_application_error(-20011, 'Tikslumas turi būti nuo 1 iki 1000');
        end if;

        delete from pi_calculation_step;

        for i in 0 .. p_precision - 1 loop
            l_value := power(16, -i) *
                       (4 / (8 * i + 1)
                      - 2 / (8 * i + 4)
                      - 1 / (8 * i + 5)
                      - 1 / (8 * i + 6));

            l_pi := l_pi + l_value;

            insert into pi_calculation_step(
                step_no,
                term_value,
                intermediate_value
            ) values (
                i + 1,
                l_value,
                l_pi
            );
        end loop;

        return l_pi;
    end calculate_pi;

    /* Neapmokėtos sąskaitos */
    FUNCTION get_unpaid_invoices
        return clob
    is
        l_json clob;
    begin
        select json_arrayagg(
                   json_object(
                       'invoiceId' value invoice_id,
                       'invoiceDate' value to_char(invoice_date, 'yyyy-mm-dd'),
                       'amount' value invoice_amount,
                       'currency' value currency,
                       'paidAmount' value paid_amount,
                       'unpaidAmount' value invoice_amount - paid_amount
                       returning clob
                   )
                   order by invoice_date, invoice_id
                   returning clob
               )
          into l_json
          from (
                select i.invoice_id,
                       i.invoice_date,
                       i.invoice_amount,
                       i.currency,
                       nvl(sum(p.payment_amount), 0) paid_amount
                  from invoice i
                  left join payment p
                    on p.invoice_id = i.invoice_id
                   and p.currency = i.currency
                 group by i.invoice_id,
                          i.invoice_date,
                          i.invoice_amount,
                          i.currency
                having nvl(sum(p.payment_amount), 0) < i.invoice_amount
               );

        return nvl(l_json, to_clob('[]'));
    end get_unpaid_invoices;

end pkg_homework;
/

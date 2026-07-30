create or replace PACKAGE pkg_homework as
	
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
    
create or replace PACKAGE BODY pkg_homework as
	v_rowid rowid;
	function logger(
		p_msg_type   varchar2,
		p_msg_header varchar2,
		p_msg_body   varchar2,
		p_rowid      rowid default null
	) return rowid
	is
		pragma autonomous_transaction;

		v_msg_type   varchar2(20)   := substrb(p_msg_type,   1, 20);
		v_msg_header varchar2(100)  := substrb(p_msg_header, 1, 100);
		v_msg_body   varchar2(4000) := substrb(p_msg_body,   1, 4000);
	begin
		if p_rowid is null then
			insert into logger_items
			(
				event_date,
				msg_type,
				msg_header,
				msg_body
			)
			values
			(
				sysdate,
				v_msg_type,
				v_msg_header,
				v_msg_body
			)
			returning rowid into v_rowid;

		else
			update logger_items
			   set event_date = sysdate,
				   msg_type = case
								  when p_msg_type is not null
								  then v_msg_type
								  else msg_type
							  end,
				   msg_header = case
									when p_msg_header is not null
									then v_msg_header
									else msg_header
								end,
				   msg_body = case
								  when p_msg_body is not null
								  then v_msg_body
								  else msg_body
							  end
			where rowid = p_rowid;

			if sql%rowcount = 0 then
				insert into logger_items
				(
					event_date,
					msg_type,
					msg_header,
					msg_body
				)
				values
				(
					sysdate,
					v_msg_type,
					v_msg_header,
					v_msg_body
				)
				returning rowid into v_rowid;
			end if;

		end if;

		commit;
		return v_rowid;

	end logger;

    /* amžiaus grupė */
    function get_age_description(
        p_age in number
    ) return varchar2
    is
        l_description age_category.description%type;
        v_age number:=least(p_age, 999);
    begin
		v_rowid := logger( p_msg_type => 'START', p_msg_header => 'get_age_description', p_msg_body => null);
		
        if p_age is null or p_age < 0 or p_age != trunc(p_age) then
			v_rowid := logger( p_msg_type => 'ERROR', p_msg_header => null, p_msg_body => 'Amžius turi būti teigiamas sveikasis skaičius', p_rowid => v_rowid);
            raise_application_error(-20001, 'Amžius turi būti teigiamas sveikasis skaičius');
        end if;    

        select description
          into l_description
        from age_category
        where v_age between age_from  and age_to;
		
		v_rowid := logger( p_msg_type => 'SUCCESS', p_msg_header => null, p_msg_body => l_description, p_rowid => v_rowid);
        return l_description;
		
    exception
        when no_data_found then
			v_rowid := logger( p_msg_type => 'ERROR', p_msg_header => null, p_msg_body => 'Amžiui ' || p_age || ' grupė nerasta', p_rowid => v_rowid);
            raise_application_error(-20002, 'Amžiui ' || p_age || ' grupė nerasta');
        when too_many_rows then /*šitas tikrinimas jau nebūtinas*/
			v_rowid := logger( p_msg_type => 'ERROR', p_msg_header => null, p_msg_body => 'Amžiui ' || p_age || ' rasta daugiau nei viena grupė', p_rowid => v_rowid);
            raise_application_error(-20003, 'Amžiui ' || p_age || ' rasta daugiau nei viena grupė');
		when others then	
			v_rowid := logger( p_msg_type => 'ERROR', p_msg_header => null, p_msg_body => SQLCODE || chr(10) ||  SQLERRM, p_rowid => v_rowid);
			raise;
    end get_age_description;

    /* PI skaičiavimas */
    FUNCTION calculate_pi(
        p_precision in pls_integer
    ) return number
    is
        l_pi    number := 0;
        l_value number;
    begin
		v_rowid := logger( p_msg_type => 'START', p_msg_header => 'calculate_pi', p_msg_body => null);
		
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
		v_rowid := logger( p_msg_type => 'SUCCESS', p_msg_header => null, p_msg_body => l_pi, p_rowid => v_rowid);
        return l_pi;
		
	exception
		when others then	
			v_rowid := logger( p_msg_type => 'ERROR', p_msg_header => null, p_msg_body => SQLCODE || chr(10) ||  SQLERRM, p_rowid => v_rowid);
			raise;	
    end calculate_pi;

    /* Neapmokėtos sąskaitos */
    FUNCTION get_unpaid_invoices
        return clob
    is
        l_json clob;
    begin
		/*v_rowid priskiriamas funkcijos pradžioje ir jos vykdymo metu nesikeičia.*/
		v_rowid := logger( p_msg_type => 'START', p_msg_header => 'get_unpaid_invoices', p_msg_body => null);
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
			   
		v_rowid := logger( p_msg_type => 'SUCCESS', p_msg_header => null, p_msg_body => null, p_rowid => v_rowid);

        return nvl(l_json, to_clob('[]'));
	exception
		when others then	
			v_rowid := logger( p_msg_type => 'ERROR', p_msg_header => null, p_msg_body => SQLCODE || chr(10) ||  SQLERRM, p_rowid => v_rowid);
			raise;	
    end get_unpaid_invoices;

end pkg_homework;
/
/

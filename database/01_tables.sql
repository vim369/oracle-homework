CREATE TABLE age_category
(
    description VARCHAR2(100) NOT NULL,
    age_from    NUMBER(3) NOT NULL,
    age_to      NUMBER(3) NOT NULL,

    CONSTRAINT pk_age_category
        PRIMARY KEY (description),

    CONSTRAINT ck_age_category_from
        CHECK (age_from >= 0),

    CONSTRAINT ck_age_category_to
        CHECK (age_to <= 999),

    CONSTRAINT ck_age_category_range
        CHECK (age_from <= age_to)
);

CREATE OR REPLACE TRIGGER trg_age_category_overlap
AFTER INSERT OR UPDATE ON age_category
DECLARE
    l_count INTEGER;
BEGIN
    SELECT COUNT(1) INTO l_count
	FROM age_category a
	JOIN age_category b
	ON a.ROWID != b.ROWID /*kad eilutė nebūtų lyginama su pačia savimi*/
	AND a.age_from <= b.age_to AND a.age_to >= b.age_from;
 
    if l_count>0 then 
    raise_application_error(
        -20001,
        'Age ranges must not overlap'
    );
	end if;
	
END;

CREATE GLOBAL TEMPORARY TABLE pi_calculation_step
(
    step_no             number not null,
    term_value          number not null,
    intermediate_value  number not null,
	created_at          timestamp default systimestamp not null
)
ON COMMIT PRESERVE ROWS;

create table invoice (
    invoice_id      number not null,
    invoice_date    date not null,
    invoice_amount  number not null,
    currency        varchar2(3 char) not null,
    constraint pk_invoice primary key (invoice_id)
);

create table payment (
    payment_id      number not null,
    payment_date    date not null,
    payment_amount  number not null,
    currency        varchar2(3 char) not null,
    invoice_id      number not null,
    constraint pk_payment primary key (payment_id),
    constraint fk_payment_invoice foreign key (invoice_id) references invoice(invoice_id)
);

create index ix_payment_invoice_currency on payment(invoice_id, currency);

CREATE TABLE logger_items
(
    event_date  DATE          DEFAULT SYSDATE NOT NULL,
    msg_type    VARCHAR2(20 BYTE),
    msg_header  VARCHAR2(100 BYTE),
    msg_body    VARCHAR2(4000 BYTE)
);

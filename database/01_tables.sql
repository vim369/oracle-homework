create table age_category (
    age_from     number(3) not null,
    age_to       number(3),
    description  varchar2(100 char) not null
);

create table pi_calculation_step (
    step_no             number not null,
    term_value          number not null,
    intermediate_value  number not null,
    created_at          timestamp default systimestamp not null,
    constraint pk_pi_calculation_step primary key (step_no)
);

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

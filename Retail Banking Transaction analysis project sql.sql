-- Sprint 2 :  Design the Database from the ER Diagram and Data Import

create database Bank_Transaction;
use Bank_Transaction;

create table customers(
	customer_id varchar(20) primary key,
    first_name varchar(50) not null,
    last_name varchar(50)not null,
    date_of_birth date not null,
    gender varchar(20),
    city varchar(50),
    state varchar(30),
    customer_since date not null,
    kyc_status varchar(20) not null,
    segment varchar(30) not null,
    annual_income decimal(12,0) check (annual_income >= 0),
    credit_score int check (credit_score >= 0),
    is_active varchar(3)
);

create table branches(
	branch_id varchar(10) primary key,
    branch_name varchar(30) not null,
    city varchar(50),
    state varchar(30),
    region varchar(30),
    opening_date date not null,
    employee_count int
);

create table accounts(
	account_id varchar(20) primary key,
    account_type varchar(30) not null,
    open_date date not null,
    close_date date,
    current_balance decimal(15,2) check (current_balance >= 0),
    interest_rate decimal(5,2) check (interest_rate >= 0 ),
    overdraft_limit decimal(12,2) check (overdraft_limit >= 0),
    status varchar(20),

    customer_id varchar(20) not null,
    foreign key (customer_id) references customers(customer_id),
	branch_id varchar(10) not null,
	foreign key (branch_id) references branches(branch_id)
);

create table loans(
	loan_id varchar(20) primary key,
    customer_id varchar(20) not null,
    foreign key (customer_id) references customers(customer_id),
    branch_id varchar(10) not null,
	foreign key (branch_id) references branches(branch_id),
    loan_type varchar(30) not null,
    principal_amount decimal(15,2) check (principal_amount >= 0),
    interest_rate decimal(5,2) check (interest_rate >= 0),
    tenure_months int check (tenure_months > 0),
    disbursement_date date,
    maturity_date date,
    emi_amount decimal(12,2) check (emi_amount >= 0),
    outstanding_balance decimal(15,2) check (outstanding_balance >= 0),
    loan_status varchar(30) not null,
    purpose varchar(50)
);

create table loan_payments(
	payment_id varchar(20) primary key,
    loan_id varchar(20) not null,
    foreign key (loan_id) references loans (loan_id),
    payment_date date not null,
    scheduled_amount decimal(12,0) check (scheduled_amount >= 0),
    paid_amount decimal(12,2) check (paid_amount >= 0),
    principal_paid decimal (12,2) check (principal_paid >= 0),	
    interest_paid decimal (12,2) check (interest_paid >= 0),
    penalty decimal(12,2) check (penalty >= 0),
    days_late int check (days_late >= 0),
    payment_method varchar(30),
    status varchar(20)
);

create table cards(
	card_id varchar(20) primary key,
    account_id varchar(20) not null,
    foreign key (account_id) references accounts (account_id),
    card_type varchar(20) not null,
    issue_date date not null,
    expiry_date date not null,
    credit_limit decimal(12,2) check (credit_limit >= 0),
    outstanding_balance decimal (12,2) check (outstanding_balance >= 0),
    reward_points int check (reward_points >= 0),
    is_active varchar(3),
    network varchar(20)
);

create table transactions(
	transaction_id varchar(20) primary key,
    account_id varchar(20) not null,
    foreign key (account_id) references accounts (account_id),
    transaction_date date not null,
    transaction_time time not null,
    transaction_type varchar(30) not null,
    amount decimal (15,2) check (amount >= 0),
    channel varchar(30),
    description varchar(50),
    balance_after decimal(15,2),
    status varchar(20)
);

select count(*) from branches;
select count(*) from customers;
select count(*) from accounts;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE accounts;

SET FOREIGN_KEY_CHECKS = 1;

select count(*) from accounts;

alter table accounts
modify column close_date varchar(30);

set sql_safe_updates = 0;
update accounts set close_date = null where close_date = "";
select * from accounts;


select count(*) from accounts;

-- count of close_date having null = ''
select count(*) from accounts where close_date = '';
-- count of close_date having no null values 
select count(*) from accounts where close_date != '';
-- 700 = null values '' + 203(not null values)

select count(*) from loans;
select count(*) from loan_payments;
select count(*) from cards;
select count(*) from transactions;

-- Sprint 3: Basic Analysis / Data Exploration
-- Write SQL queries to answer the following basic questions. The purpose of this sprint is to become familiar with the database before moving into objective-based analysis.
-- 11. What is the total number of customers?
select count(*) from customers;

-- 12. What is the total number of accounts?
select count(*) from accounts;

-- 13. What are the different account types available?
select account_type from accounts group by account_type;

-- 14. How many customers are currently active?
select count(*) as active_customers from customers where is_active = "Yes";

-- 15. What are the different transaction types available?
select transaction_type from transactions group by transaction_type;

-- 16. What is the total amount of completed transactions?
select sum(amount) from transactions where status = "Completed";

-- 17. What are the different loan types available?
select * from loans;
select loan_type from loans group by loan_type;

-- 18. What is the total number of loans?
select count(*) from loans;

-- 19. What are the different card types available?
select card_type from cards group by card_type;

-- 20. What is the total outstanding loan balance?
select * from cards;
select sum(outstanding_balance) from cards;

-- Sprint 4 : Objective-Based Analysis
-- 4.1 : Understand Customer Profile and Segmentation
-- 1. Which customer has the highest annual income?
select customer_id,first_name,last_name,annual_income from customers
order by annual_income desc limit 1;

-- 2. Which customer segment has the most customers?
select segment,count(*) from customers group by segment order by count(*) desc limit 1;

-- 3. How many customers have a verified KYC status and are currently active?
select customer_id,first_name,last_name,kyc_status,is_active from customers where kyc_status = "Verified" and is_active = "Yes";

-- 4. What is the average annual income by customer segment?
select segment,avg(annual_income)  from customers group by segment;

-- 5. Which state has the highest total annual income among customers?
select state,sum(annual_income) from customers group by state order by sum(annual_income) desc limit 1;
select * from customers;

-- 6. In state TN, which city has customers with the highest average credit score and average annual income?
select city,avg(credit_score),avg(annual_income) from customers where state = "TN" group by city order by avg(credit_score) and avg(annual_income) desc limit 1;

-- 7. Which customer segment has the highest average annual income?
select segment,avg(annual_income) from customers group by segment order by avg(annual_income) desc limit 1;

-- 8. which branch has highest number of accounts
select branch_name, count(account_id) from branches join accounts on branches.branch_id = accounts.branch_id group by branch_name order by count(account_id) desc limit 1;

-- 9. How many customers have an active loan status?
select count(customers.customer_id) from customers join loans on customers.customer_id = loans.customer_id where loans.loan_status = "Active";

-- 10. Which customer has the highest interest rate on their loan, and what type of loan do they have? 
select customers.customer_id,loan_type,loans.interest_rate from customers join loans on customers.customer_id = loans.customer_id order by loans.interest_rate desc limit 1;


-- 4.2 Understand Account Usage and Branch Activity
-- 1. Which account type has the highest average current balance?
select account_type,avg(current_balance) from accounts group by account_type order by avg(current_balance) desc limit 1;

-- 2. Which account types have more than 100 accounts?
select account_type,count(account_id) from accounts group by account_type having count(account_id) > 100;

-- 3. Which branch has the highest total current balance across its accounts?
select branches.branch_name,branches.branch_id,sum(accounts.current_balance) as total_balance from branches join accounts on accounts.branch_id = branches.branch_id
group by branch_name,branch_id order by total_balance desc limit 1;

-- 4. Which customer has the highest total account balance across all their accounts?
select customers.customer_id,sum(accounts.current_balance) as total_bal from customers join accounts on
customers.customer_id = accounts.customer_id group by customers.customer_id order by total_bal desc limit 1;

-- 5. Which branch has the highest number of active accounts?
select branches.branch_id,branches.branch_name,count(accounts.account_id) as account_active from branches join accounts on branches.branch_id = accounts.branch_id
where accounts.status = "Active" group by branches.branch_id order by account_active desc limit 1;

-- 6. Which account has a current balance higher than the average current balance of all accounts?
select account_id from accounts where current_balance > (select avg(current_balance) from accounts);

-- 7. Which branch has the highest number of customers holding accounts?
select branches.branch_id,branches.branch_name,count(distinct customers.customer_id) as cust_count from branches join accounts on 
branches.branch_id = accounts.branch_id join customers on customers.customer_id = accounts.customer_id where accounts.status = "Active"
group by branches.branch_id,branches.branch_name order by cust_count desc limit 1;

-- 8. display account types whose average interest rate is greater than the overall average interest rate of all accounts.
delimiter //
create procedure account_type()
begin 
select account_type,avg(interest_rate) as avg_interest from accounts group by account_type 
having avg(interest_rate) > (select avg(interest_rate) from accounts);
end //
delimiter 
call account_type;

-- 4.3 Analyze Transaction Patterns 
-- 1. Which transaction type has the highest total transaction amount?
select transaction_type,sum(amount) as total_amount from transactions group by transaction_type order by total_amount desc limit 1;

-- 2. Which transaction channels have more than 500 transactions?
select * from transactions;
select channel,count(transaction_id) from transactions group by channel having count(transaction_id) > 500;

-- 3. Which account has the highest total transaction amount?
select accounts.account_id,sum(transactions.amount) from accounts join transactions on accounts.account_id = transactions.account_id
group by accounts.account_id order by sum(transactions.amount) desc limit 1;

-- 4. Which customer has the highest total amount of completed transactions?
select customers.customer_id,sum(transactions.amount) as total_amount from transactions join accounts on transactions.account_id = accounts.account_id
join customers on accounts.customer_id = customers.customer_id 
where transactions.status = "Completed" group by customers.customer_id order by sum(transactions.amount) desc limit 1;

-- 5. For each transaction type, what are the total number of transactions and the average transaction amount?
select transaction_type,count(transaction_id),avg(amount) from transactions group by transaction_type;

-- 6. Which transactions have an amount greater than the average transaction amount?
select transaction_id from transactions where amount > (select avg(amount) from transactions);

-- 7. Which customers have completed transactions with a total transaction amount greater than 100,000?
select customers.customer_id,sum(transactions.amount) as total_amount from transactions join accounts on transactions.account_id = accounts.account_id
join customers on accounts.customer_id = customers.customer_id where transactions.status = "Completed" group by customers.customer_id having total_amount > 100000;

-- 8. Create a stored procedure that displays transaction channels 
-- whose average transaction amount is greater than the overall average transaction amount.
delimiter //
create procedure res()
begin 
select channel,avg(amount) from transactions group by channel having avg(amount) > (select avg(amount) from transactions);
end //
delimiter 
call res();

-- 4.4 — Loan Performance & Repayment
-- 1. Which loan type has the highest total principal amount?
select loan_type,sum(principal_amount) from loans group by loan_type order by sum(principal_amount) desc limit 1;

-- 2. Which loan types have more than 50 loans?
select loan_type,count(loan_id) from loans group by loan_type having count(loan_id) > 50;

-- 3. Which branch has the highest total outstanding loan balance?
select branches.branch_id,branches.branch_name,sum(loans.outstanding_balance) from branches join loans on branches.branch_id = loans.branch_id group by branches.branch_id,
branches.branch_name order by sum(loans.outstanding_balance) desc limit 1;

-- 4. Which customer has the highest total outstanding loan balance among active loans?
select customers.customer_id,sum(loans.outstanding_balance) from customers join loans on customers.customer_id = loans.customer_id
where loans.loan_status = "Active" group by customers.customer_id order by sum(loans.outstanding_balance) desc limit 1;

-- 5. For each loan type, what are the total number of loans and the average outstanding balance?
select loan_type,count(loan_id),avg(outstanding_balance) from loans group by loan_type;

-- 6. Which loans have an outstanding balance greater than the average outstanding balance of all loans?
select loan_id,loan_type,outstanding_balance from loans where outstanding_balance > (select avg(outstanding_balance) from loans);

-- 7. Which branches have a total outstanding loan balance greater than 500,000?
select branches.branch_id,branches.branch_name,sum(loans.outstanding_balance) from branches join loans on branches.branch_id = loans.branch_id
group by branches.branch_id,branches.branch_name having sum(loans.outstanding_balance) > 500000;

-- 8. Create a stored procedure that displays loan types whose average outstanding balance is greater than the overall average outstanding balance.
delimiter //
create procedure res2()
begin
select loan_type,avg(outstanding_balance) from loans group by loan_type having avg(outstanding_balance) > (select avg(outstanding_balance) from loans);
end //
delimiter 
call res2();

-- 4.5 — Card Usage & Product Engagement
-- 1. Which card type has the highest average credit limit?
select card_type,avg(credit_limit) from cards group by card_type order by avg(credit_limit) desc limit 1;

-- 2. Which card types have more than 150 cards?
select card_type,count(card_id) from cards group by card_type having count(card_id) > 150;

-- 3. Which account has the highest total outstanding balance across all its cards?
select accounts.account_id,sum(cards.outstanding_balance) from accounts join cards on accounts.account_id = cards.account_id group by 
accounts.account_id order by sum(cards.outstanding_balance) desc limit 1;

-- 4. Which customer has the highest total outstanding balance across their active cards?
select customers.customer_id,sum(cards.outstanding_balance) from customers join accounts on customers.customer_id = accounts.customer_id
join cards on accounts.account_id = cards.account_id where cards.is_active = "Yes" group by customers.customer_id order by
sum(cards.outstanding_balance) desc limit 1;

-- 5. For each card type, what are the total number of cards and the average reward points?
select card_type,count(card_id),avg(reward_points) from cards group by card_type;

-- 6. Which cards have a credit limit greater than the average credit limit of all cards?
select card_id,card_type,credit_limit from cards where credit_limit > (select avg(credit_limit) from cards);

-- 7. Which customers have a total card outstanding balance greater than 50,000 across their cards?
select customers.customer_id,sum(cards.outstanding_balance) from customers join accounts on customers.customer_id = accounts.customer_id
join cards on accounts.account_id = cards.account_id group by customers.customer_id having sum(cards.outstanding_balance) > 50000;

-- 8. Create a stored procedure that displays card types whose average reward points are greater than the overall average reward points.
delimiter //
create procedure res1()
begin
select card_type,avg(reward_points) from cards group by card_type having avg(reward_points) > (select avg(reward_points) from cards);
end //
delimiter 
call res1();
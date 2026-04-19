create database Customers_transactions;
update customers set Gender = null where Gender ='';
update customers set Age = null where Age ='';
alter table customers modify Age int null;

select*from customers;

create table Transactions
(date_new date,
Id_check int,
ID_client int,
Count_products decimal(10,3),
Sum_payment decimal(10,2));

load data infile "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TRANSACTIONS_final.csv"
into table Transactions
fields terminated by ','
lines terminated by '\n'
ignore 1 rows ;

show variables like 'secure_file_priv';
select*from Transactions;

#1
WITH MonthlyActivity AS (
    SELECT 
        ID_client,
        COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) as active_months,
        AVG(Sum_payment) as avg_check,
        SUM(Sum_payment) / 12 as avg_monthly_spent,
        COUNT(id_check) as total_operations
    FROM Transactions
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY ID_client
)
SELECT * FROM MonthlyActivity 
WHERE active_months = 12; -- Только те, кто был активен все 12 месяцев

#2
SELECT 
    DATE_FORMAT(t.date_new, '%Y-%m') as month,
    AVG(t.Sum_payment) as avg_check_monthly, -- a)
    COUNT(t.id_check) / COUNT(DISTINCT t.ID_client) as avg_ops_per_client, -- b)
    COUNT(DISTINCT t.ID_client) as unique_clients, -- c)
    -- d) Доля операций и суммы от годовых (используем оконные функции)
    COUNT(t.id_check) / SUM(COUNT(t.id_check)) OVER() as ops_share,
    SUM(t.Sum_payment) / SUM(SUM(t.Sum_payment)) OVER() as sum_share,
    -- e) М/Ж/NA соотношение и доля затрат
    COUNT(CASE WHEN c.Gender = 'M' THEN 1 END) / COUNT(*) * 100 as male_pct,
    COUNT(CASE WHEN c.Gender = 'F' THEN 1 END) / COUNT(*) * 100 as female_pct,
    SUM(CASE WHEN c.Gender = 'M' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) as male_spend_share
FROM Transactions t
JOIN customers c ON t.ID_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month;

#3
SELECT 
    CASE 
        WHEN Age IS NULL THEN 'No Data'
        ELSE CONCAT(FLOOR(Age / 10) * 10, '-', FLOOR(Age / 10) * 10 + 9)
    END as age_group,
    QUARTER(t.date_new) as quarter,
    SUM(t.Sum_payment) as total_sum,
    COUNT(t.id_check) as total_ops,
    AVG(t.Sum_payment) as avg_payment
FROM customers c
JOIN Transactions t ON c.Id_client = t.ID_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY age_group, quarter
ORDER BY age_group, quarter;

















SELECT 
    p.category,
    c.state,
    SUM(p.price * oi.quantity) AS total_revenue
FROM 
    order_items oi
JOIN 
    products p ON oi.product_id = p.product_id
JOIN 
    orders o ON oi.order_id = o.order_id
JOIN 
    customers c ON o.customer_id = c.customer_id
WHERE 
    o.order_date IS NOT NULL -- Assuming completed orders have a non-null date
GROUP BY 
    p.category, c.state;

SELECT 
    p.category,
    o.customer_id,
    SUM(p.price * oi.quantity) AS total_spent
FROM 
    order_items oi
JOIN 
    products p ON oi.product_id = p.product_id
JOIN 
    orders o ON oi.order_id = o.order_id
GROUP BY 
    p.category, o.customer_id
HAVING 
    SUM(p.price * oi.quantity) = (
        SELECT MAX(total_spent) FROM (
            SELECT 
                o.customer_id,
                SUM(p.price * oi.quantity) AS total_spent
            FROM 
                order_items oi
            JOIN 
                products p ON oi.product_id = p.product_id
            JOIN 
                orders o ON oi.order_id = o.order_id
            GROUP BY 
                p.category, o.customer_id
        ) AS subquery
    );


SELECT 
    o.order_date,
    oi.product_id,
    AVG(oi.quantity) OVER (
        PARTITION BY oi.product_id 
        ORDER BY o.order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
    ) AS rolling_7_day_avg
FROM 
    order_items oi
JOIN 
    orders o ON oi.order_id = o.order_id;



SELECT 
    p.project_id,
    d.department_id,
    SUM(ep.hours_worked * e.hourly_rate) AS total_cost,
    d.budget
FROM 
    employee_projects ep
JOIN 
    employees e ON ep.employee_id = e.employee_id
JOIN 
    projects p ON ep.project_id = p.project_id
JOIN 
    departments d ON p.department_id = d.department_id
GROUP BY 
    p.project_id, d.department_id, d.budget;









WITH last_month_hours AS (
    SELECT 
        employee_id,
        SUM(hours_worked) / 4.0 AS avg_weekly_hours -- Предполагаем 4 недели в месяце
    FROM 
        employee_projects
    WHERE 
        project_date >= NOW() - INTERVAL '1 month'
    GROUP BY 
        employee_id
)
SELECT 
    employee_id,
    avg_weekly_hours
FROM 
    last_month_hours;




SELECT 
    d.department_id,
    DATE_TRUNC('quarter', project_date) AS quarter,
    SUM(ep.hours_worked * e.hourly_rate) AS total_cost
FROM 
    employee_projects ep
JOIN 
    employees e ON ep.employee_id = e.employee_id
JOIN 
    projects p ON ep.project_id = p.project_id
JOIN 
    departments d ON p.department_id = d.department_id
GROUP BY 
    d.department_id, DATE_TRUNC('quarter', project_date)
HAVING 
    SUM(ep.hours_worked * e.hourly_rate) > d.budget;

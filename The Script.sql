--Database Schema Creation

-- Create the HR Workforce Analytics Database
CREATE DATABASE HRWorkforceAnalytics;
GO

USE HRWorkforceAnalytics;
GO

-- Departments Dimension
CREATE TABLE Dim_HR_Departments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100),
    location VARCHAR(50),
    annual_budget DECIMAL(12,2)
);

-- Employees Dimension
CREATE TABLE Dim_Employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100),
    gender VARCHAR(10),
    education_level VARCHAR(50),
    hire_date DATE
);

-- Workforce Metrics & Attrition Fact Table
CREATE TABLE Fact_EmployeePerformance (
    record_id INT PRIMARY KEY,
    employee_id INT FOREIGN KEY REFERENCES Dim_Employees(employee_id),
    department_id INT FOREIGN KEY REFERENCES Dim_HR_Departments(department_id),
    performance_rating INT, -- 1 to 5 scale
    monthly_income DECIMAL(10,2),
    years_at_company INT,
    overtime_status VARCHAR(10), -- 'Yes', 'No'
    attrition_status VARCHAR(10) -- 'Active', 'Left'
);

--Data Ingestion

-- Insert Departments
INSERT INTO Dim_HR_Departments VALUES 
(1, 'Software Engineering', 'New York', 2500000.00),
(2, 'Sales & Marketing', 'Chicago', 1800000.00),
(3, 'Human Resources', 'New York', 800000.00),
(4, 'Finance & Accounting', 'Chicago', 1500000.00);

-- Insert Employees
INSERT INTO Dim_Employees VALUES 
(1001, 'Alexander Wright', 'Male', 'Master', '2019-06-15'),
(1002, 'Sophia Martinez', 'Female', 'Bachelor', '2021-03-01'),
(1003, 'Liam O Connor', 'Male', 'Master', '2018-11-20'),
(1004, 'Emma Johnson', 'Female', 'PhD', '2022-01-10'),
(1005, 'Noah Smith', 'Male', 'Bachelor', '2023-05-12'),
(1006, 'Olivia Davis', 'Female', 'Master', '2020-08-18');

-- Insert Performance & Attrition Records
INSERT INTO Fact_EmployeePerformance VALUES 
(1, 1001, 1, 4, 9500.00, 7, 'No', 'Active'),
(2, 1002, 2, 3, 6200.00, 5, 'Yes', 'Left'),
(3, 1003, 1, 5, 11000.00, 8, 'No', 'Active'),
(4, 1004, 4, 4, 8800.00, 4, 'No', 'Active'),
(5, 1005, 2, 2, 4500.00, 3, 'Yes', 'Left'),
(6, 1006, 3, 4, 7500.00, 6, 'No', 'Active');


--Advanced HR Workforce Analytics & Attrition Queries

-- ============================================================================
-- QUERY 1: Departmental Attrition Rate & Active Headcount
-- Business Goal: Measure employee retention stability and flight risk across departments.
-- ============================================================================

SELECT 
    d.department_name,
    d.location,
    COUNT(e.employee_id) AS total_headcount,
    -- Count employees who left
    SUM(CASE WHEN f.attrition_status = 'Left' THEN 1 ELSE 0 END) AS total_departures,
    -- Calculate Attrition Rate Percentage
    ROUND((SUM(CASE WHEN f.attrition_status = 'Left' THEN 1.0 ELSE 0.0 END) / COUNT(e.employee_id)) * 100, 2) AS attrition_rate_pct
FROM Fact_EmployeePerformance f
JOIN Dim_HR_Departments d ON f.department_id = d.department_id
JOIN Dim_Employees e ON f.employee_id = e.employee_id
GROUP BY d.department_name, d.location
ORDER BY attrition_rate_pct DESC;


-- ============================================================================
-- QUERY 2: Compensation vs. Performance Rating Analysis
-- Business Goal: Evaluate if high-performing employees are adequately compensated relative to tenure.
-- ============================================================================

SELECT 
    e.employee_name,
    d.department_name,
    e.education_level,
    f.performance_rating,
    f.monthly_income,
    f.years_at_company,
    f.overtime_status,
    f.attrition_status
FROM Fact_EmployeePerformance f
JOIN Dim_Employees e ON f.employee_id = e.employee_id
JOIN Dim_HR_Departments d ON f.department_id = d.department_id
WHERE f.performance_rating >= 4 AND f.attrition_status = 'Active'
ORDER BY f.monthly_income DESC;


-- ============================================================================
-- QUERY 3: Salary Ranking by Department using Window Functions
-- Business Goal: Rank employee salaries within each department using advanced window functions.
-- ============================================================================

WITH Department_Salary_Ranking AS (
    SELECT 
        d.department_name,
        e.employee_name,
        f.monthly_income,
        f.performance_rating,
        f.years_at_company
    FROM Fact_EmployeePerformance f
    JOIN Dim_Employees e ON f.employee_id = e.employee_id
    JOIN Dim_HR_Departments d ON f.department_id = d.department_id
)
SELECT 
    department_name,
    employee_name,
    monthly_income,
    performance_rating,
    years_at_company,
    -- Rank employee salaries within each department using a window function
    DENSE_RANK() OVER (PARTITION BY department_name ORDER BY monthly_income DESC) AS salary_rank_in_department
FROM Department_Salary_Ranking
ORDER BY department_name, salary_rank_in_department;
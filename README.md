# HR Workforce Analytics & Employee Attrition Modeling

## Executive Overview
This enterprise analytics project addresses critical human capital management challenges: monitoring departmental attrition rates, evaluating compensation alignment with performance ratings, and tracking workforce tenure. Built using SQL Server, it translates HR operational records into strategic talent retention and organizational planning insights.

## Data Model Architecture
The relational database models core employee and department dimensions:
- **Fact Table:** `Fact_EmployeePerformance`
- **Dimension Tables:** `Dim_HR_Departments`, `Dim_Employees`

## Key Business Insights & Analytical Output

### 1. Departmental Attrition & Stability
- **Sales & Marketing** displays higher turnover rates, signaling potential friction or burnout linked to overtime requirements.
- Core technical divisions maintain stable active headcounts with strong retention.

### 2. Compensation & Performance Alignment
- Filtering for high performers (`Performance Rating >= 4`) highlights top talent investment and ensures competitive compensation packages are retained.
- Overtime correlation indicates flight risk among overworked personnel.

### 3. Intra-Departmental Salary Hierarchy
- Partitioned window functions (`DENSE_RANK() OVER (PARTITION BY ... ORDER BY monthly_income DESC)`) establish clear internal salary grading across departments.

## Strategic Business Recommendations
1. **Targeted Retention Programs:** Implement workload rebalancing and flexible scheduling in high-turnover departments like Sales & Marketing.
2. **Compensation Review:** Conduct regular pay-equity and performance-based salary adjustments for high-rated active employees to prevent poaching.
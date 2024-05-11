SELECT employee_id, first_name, hire_date, department_name, salary, TRUNC((SYSDATE - hire_date)/365.25) AS "WORKING YEARS' EXPERIENCE",
CASE WHEN employee_id IN (SELECT DISTINCT(manager_id) FROM employees WHERE manager_id IS NOT NULL) THEN '                  Y'
ELSE '                  N'
END AS "Managerial Position",
DECODE(SIGN(TRUNC((SYSDATE - hire_date)/365.25)-14), 1, '15 Years Rewards','NULL') REMARKS
FROM employees JOIN departments ON (employees.department_id = departments.department_id) JOIN locations ON (departments.location_id = locations.location_id)
WHERE TRUNC((SYSDATE - hire_date)/365.25)> '&1' AND locations.country_id= '&2'
AND employee_id NOT IN (SELECT DISTINCT(employee_id) FROM job_history);
SELECT employee_id, UPPER(first_name ||' '||last_name) AS NAME, hire_date, TO_CHAR(SYSDATE, 'DD-MM-RRRR') AS TODAY, TRUNC((SYSDATE - hire_date)/365.25) AS "WORKING YEARS", department_name, job_title, REPLACE(TO_CHAR(salary,'999999990.00'),' ', '*') AS SALARY
FROM employees JOIN departments ON (employees.department_id = departments.department_id) JOIN jobs ON (employees.job_id = jobs.job_id)
WHERE TRUNC((SYSDATE - hire_date)/365.25) < '&working_experience'
AND departments.department_name = '&department_name'
AND salary >'&salary'
AND jobs.job_id = '&job_id';
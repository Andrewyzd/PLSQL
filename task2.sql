	ACCEPT input_employeeID NUMBER PROMPT 'Enter the employee id: ';
	ACCEPT input_startDATE DATE PROMPT 'Enter the start date as DD-MON-YY: ';
	ACCEPT input_endDATE DATE PROMPT 'Enter the end date as DD-MON-YY: ';
	ACCEPT input_jobID PROMPT 'Enter the job id: ';
	ACCEPT input_departmentID NUMBER PROMPT 'Enter the department id: ';

CREATE OR REPLACE PROCEDURE add_job_history AS

	--variable declaration
	v_employeeID NUMBER(6) := &input_employeeID;
	v_startDATE DATE := '&input_startDATE';
	v_endDATE DATE := '&input_endDATE';
	v_jobID VARCHAR2(10) := '&input_jobID';
	v_departmentID NUMBER(4) := &input_departmentID;

	v_idCheck NUMBER(6);
	v_dateCheck DATE;
	v_jodIDCheck VARCHAR2(10);
	v_departmentIDCheck NUMBER(4);

	--exception declaration
	ex_PREVIOUS_NEXT_DATE EXCEPTION;
	ex_HIRE_START_DATE EXCEPTION;
	ex_START_LESS_END_DATE EXCEPTION;
	ex_JOB_DEPARTMENT EXCEPTION;

BEGIN
	--check the existance of the employees' id in both job_history and employees tables 

	SELECT count(*) INTO v_idCheck FROM job_history WHERE job_history.employee_id = v_employeeID;	
	
	IF(v_idCheck > 0) THEN
		SELECT MAX(end_date) INTO v_dateCheck FROM job_history WHERE employee_id = v_employeeID;
		IF(v_startDATE <> v_dateCheck + 1) THEN
			DBMS_OUTPUT.PUT_LINE('The employee record has existed and the last end date is ' ||v_dateCheck);
			RAISE ex_PREVIOUS_NEXT_DATE;
		END IF;
	ELSE
		SELECT count(*) INTO v_idCheck FROM employees WHERE employee_id = v_employeeID;
		IF(v_idCheck = 1) THEN
			SELECT hire_date INTO v_dateCheck FROM employees WHERE employee_id = v_employeeID;
			IF(v_startDATE <> v_dateCheck) THEN
				DBMS_OUTPUT.PUT_LINE('The hire date for this employee is '||v_dateCheck);
				RAISE ex_HIRE_START_DATE;
			END IF;
		ELSE
			RAISE NO_DATA_FOUND;
		END IF;
	END IF;
	
	--check whether the end date is greather than the start date
	IF(v_endDATE < v_startDATE) THEN
		RAISE ex_START_LESS_END_DATE; 
	END IF;
	
	--check for job id and department id
	SELECT job_id, department_id INTO v_jodIDCheck, v_departmentIDCheck FROM employees WHERE employee_id = v_employeeID;
	IF(v_jobID <> v_jodIDCheck OR v_departmentIDCheck <> v_departmentID) THEN
		DBMS_OUTPUT.PUT_LINE('The job id and department id of the employee is ' ||v_jodIDCheck||' and '||v_departmentIDCheck);
		RAISE ex_JOB_DEPARTMENT;
	END IF; 
	
	--Display the details
	DBMS_OUTPUT.PUT_LINE('---Your entered details---');
	DBMS_OUTPUT.PUT_LINE('Employee ID: '|| v_employeeID);
	DBMS_OUTPUT.PUT_LINE('Start Date: '|| v_startDATE);
	DBMS_OUTPUT.PUT_LINE('End Date: '|| v_endDATE);
	DBMS_OUTPUT.PUT_LINE('Job ID: '|| v_jobID);
	DBMS_OUTPUT.PUT_LINE('Department ID: '|| v_departmentID);
	
	--Insert the value into the job_history table
	INSERT INTO job_history VALUES(v_employeeID, v_startDATE, v_endDATE, v_jobID, v_departmentID);
	DBMS_OUTPUT.PUT_LINE('RECORD INSERTED SUCCESSFULLY!');
	
	COMMIT; --Record the data permanently

EXCEPTION
	WHEN ex_PREVIOUS_NEXT_DATE THEN
		DBMS_OUTPUT.PUT_LINE('The start date entered '||v_startDATE||' must be the next date of the previous end date for existing employee.');
		DBMS_OUTPUT.PUT_LINE('INSERTION UNSUCCESSFULL!');
		ROLLBACK;

	WHEN ex_HIRE_START_DATE THEN
		DBMS_OUTPUT.PUT_LINE('The start date: '||v_startDATE||' must be same as the hire date for new entry employee');
		DBMS_OUTPUT.PUT_LINE('INSERTION UNSUCCESSFULL!');
		ROLLBACK;

	WHEN ex_START_LESS_END_DATE THEN
		DBMS_OUTPUT.PUT_LINE('The end date: ' ||v_endDATE||' cannot be less than the start date: '||v_startDATE);
		DBMS_OUTPUT.PUT_LINE('INSERTION UNSUCCESSFULL!');
		ROLLBACK;

	WHEN ex_JOB_DEPARTMENT THEN
		DBMS_OUTPUT.PUT_LINE('The entered job id ('||v_jobID||') and department id ('||v_departmentID||') must be same as in employees tables');
		DBMS_OUTPUT.PUT_LINE('INSERTION UNSUCCESSFULL!');
		ROLLBACK;

	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('The employee id: '|| v_employeeID ||' do not exist!');
		DBMS_OUTPUT.PUT_LINE('ERROR CODE: ' || SQLCODE);
		DBMS_OUTPUT.PUT_LINE('Error Details: ' || SQLERRM);
		DBMS_OUTPUT.PUT_LINE('INSERTION UNSUCCESSFULL!');
		ROLLBACK;
	
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Unable to insert the record!');
		DBMS_OUTPUT.PUT_LINE('ERROR CODE: ' || SQLCODE);
		DBMS_OUTPUT.PUT_LINE('Error Details: ' || SQLERRM);
		DBMS_OUTPUT.PUT_LINE('INSERTION UNSUCCESSFULL!');
		ROLLBACK;	

END;
/
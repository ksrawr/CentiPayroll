
INSERT INTO Company (id, name, email, password)
VALUES ('1', 'SFSUBookstore', 'sfsu@sfsu.com', 'sfsu');
INSERT INTO Company (id, name, email, password)
VALUES ('2', 'McDonalds', 'McDonalds@gmail.com', 'McDonalds');
INSERT INTO Company (id, name, email, password)
VALUES ('3', 'BurgerKing', 'BurgerKing@gmail.com', 'BurgerKing');

<<<<<<< HEAD
INSERT INTO Login (id, session_id, expiration, Company_id)
VALUES ('1', '123456789', '04242019', '1');
INSERT INTO Login (id, session_id, expiration, Company_id)
VALUES ('2', '234567891', '04242019', '2');
INSERT INTO Login (id, session_id, expiration, Company_id)
=======
INSERT INTO Login (id, session_id, expiration, company_id)
VALUES ('1', '123456789', '04242019', '1');
INSERT INTO Login (id, session_id, expiration, company_id)
VALUES ('2', '234567891', '04242019', '2');
INSERT INTO Login (id, session_id, expiration, company_id)
>>>>>>> b3df73133f6be3e5176954d246faec113667f588
VALUES ('3', '345678912', '04242019', '3');

INSERT INTO Employee (id, name, pin, wage)
VALUES ('1', 'Abert', '1234', '12.34');
INSERT INTO Employee (id, name, pin, wage)
VALUES ('2', 'Brian', '2341', '23.41');
INSERT INTO Employee (id, name, pin, wage)
VALUES ('3', 'Carlos', '3412', '34.12');

<<<<<<< HEAD
INSERT INTO Time_Card (id, time_in, time_out, Employee_id)
VALUES ('1', '1', '2', '1');
INSERT INTO Time_Card (id, time_in, time_out, Employee_id)
VALUES ('2', '2', '3', '2');
INSERT INTO Time_Card (id, time_in, time_out, Employee_id)
=======
INSERT INTO Time_Card (id, time_in, time_out, employee_id)
VALUES ('1', '1', '2', '1');
INSERT INTO Time_Card (id, time_in, time_out, employee_id)
VALUES ('2', '2', '3', '2');
INSERT INTO Time_Card (id, time_in, time_out, employee_id)
>>>>>>> b3df73133f6be3e5176954d246faec113667f588
VALUES ('3', '3', '4', '3');

INSERT INTO Report (id, start_time, end_time, hours_worked)
VALUES ('1', '1', '2', '1');
INSERT INTO Report (id, start_time, end_time, hours_worked)
VALUES ('2', '2', '3', '2');
INSERT INTO Report (id, start_time, end_time, hours_worked)
VALUES ('3', '3', '4', '3');

<<<<<<< HEAD
INSERT INTO Includes (id, Time_Card_id, Report_id)
VALUES ('1', '1', '1');
INSERT INTO Includes (id, Time_Card_id, Report_id)
VALUES ('2', '2', '2');
INSERT INTO Includes (id, Time_Card_id, Report_id)
=======
INSERT INTO Includes (id, time_card_id, report_id)
VALUES ('1', '1', '1');
INSERT INTO Includes (id, time_card_id, report_id)
VALUES ('2', '2', '2');
INSERT INTO Includes (id, time_card_id, report_id)
>>>>>>> b3df73133f6be3e5176954d246faec113667f588
VALUES ('3', '3', '3');

/*
the following was able to insert
*/
<<<<<<< HEAD
INSERT INTO Controls (id, Employee_id, Report_id, Time_Card_id, Company_id)
VALUES ('1', '1', '1', '1', '1');
INSERT INTO Controls (id, Employee_id, Report_id, Time_Card_id, Company_id)
VALUES ('2', '2', '2', '2', '2');
INSERT INTO Controls (id, Employee_id, Report_id, Time_Card_id, Company_id)
=======
INSERT INTO Controls (id, employee_id, report_id, time_card_id, company_id)
VALUES ('1', '1', '1', '1', '1');
INSERT INTO Controls (id, employee_id, report_id, time_card_id, company_id)
VALUES ('2', '2', '2', '2', '2');
INSERT INTO Controls (id, employee_id, report_id, time_card_id, company_id)
>>>>>>> b3df73133f6be3e5176954d246faec113667f588
VALUES ('3', '3', '3', '3', '3');


/*
why would Employee_id be 123456789? i thought its a FK in Controls 
INSERT INTO Controls (id, Employee_id, Report_id, Time_Card_id, Company_id)
VALUES ('1', '123456789', '1', '1', '1');
INSERT INTO Controls (id, Employee_id, Report_id, Time_Card_id, Company_id)
VALUES ('2', '234567891', '2', '2', '2');
INSERT INTO Controls (id, Employee_id, Report_id, Time_Card_id, Company_id)
VALUES ('3', '345678912', '3', '3', '3');
*/

/*Test 1*/
DELETE FROM Company WHERE id='1';
/*
if we delete Company it breaks the FK in Login
10:28:45	DELETE FROM Company WHERE id='1'	Error Code: 1451. Cannot delete or update a parent row: a foreign key constraint fails (`mydb`.`Login`, CONSTRAINT `Company_id` FOREIGN KEY (`Company_id`) REFERENCES `Company` (`id`))	0.0019 sec
*/

/*Test 2*/
DELETE FROM Controls WHERE id='1';

/*Test 3*/
DELETE FROM Employee WHERE id='1';
/*

*/

/*Test 4*/
DELETE FROM Includes WHERE id='1';
/*Test 5*/
DELETE FROM Login WHERE id='1';
/*Test 6*/
DELETE FROM Paycheck WHERE id='1';
/*Test 7*/
DELETE FROM Report WHERE id='1';
/*Test 8*/
DELETE FROM Time_Card WHERE id='1';

/*Test 9*/
SELECT Employee.id AS Employee_Id, Employee.name AS Employee_Name
FROM Employee Employee, Time_Card Time_Card, Report Report
WHERE Employee.id = Time_Card.id
AND Report.id = Employee.id;

/*Test 10*/
SELECT Employee.wage AS Employee_wage, Employee.name AS Employee_Name
FROM Employee Employee, Time_Card Time_Card, Report Report
WHERE Employee.id = Time_Card.id
AND Report.id = Employee.id;

/*Test 11*/
SELECT Time_Card.time_in AS Clock_In_Time, Time_Card.time_out AS Clock_Out_Time
FROM Employee Employee, Time_Card Time_Card, Report Report
WHERE Employee.id = Time_Card.id
AND Report.id = Time_Card.id;

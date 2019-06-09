import pdb
import re
import random
import string
from datetime import date
from flask import Flask, render_template, request, make_response, redirect
from flask_mysqldb import MySQL

app = Flask(__name__)

app.config['MYSQL_HOST'] = '127.0.0.1'
app.config['MYSQL_USER'] = 'root'
app.config['MYSQL_PASSWORD'] = 'password'
app.config['MYSQL_DB'] = 'mydb'

# app.config['MYSQL_HOST'] = 'localhost'
# app.config['MYSQL_USER'] = 'root'
# app.config['MYSQL_PASSWORD'] = 'password'
# app.config['MYSQL_DB'] = 'mydb'

mysql = MySQL(app)


def get_session_company():
    '''
    :return: id of the currently logged in Company, or None
    '''
    login_session = request.cookies.get('login_session')
    if login_session is not None:
        cur = mysql.connection.cursor()
        cur.execute(f'SELECT company_id FROM Login WHERE session_key = "{login_session}"')
        if cur.rowcount != 0:
            company_id = cur.fetchone()[0]
            cur.close()
            return company_id
        cur.close()
    return None


def login_session_company(company_id):
    cur = mysql.connection.cursor()

    key_not_generated = True
    while key_not_generated:
        random_key = ''.join(random.SystemRandom().choice(string.ascii_letters + string.digits) for _ in range(128))
        cur.execute(f'SELECT company_id FROM Login WHERE session_key = "{random_key}"')
        if cur.rowcount == 0:  # Juuuuust in case
            key_not_generated = False

    cur.execute('INSERT INTO Login(session_key, expiration, company_id) VALUES (%s, %s, %s)',
                (random_key, 0, company_id))
    mysql.connection.commit()
    resp = make_response(redirect('/home'))
    resp.set_cookie('login_session', random_key)

    cur.close()
    return resp


def logout_session_company():
    login_session = request.cookies.get('login_session')
    if login_session is not None:
        cur = mysql.connection.cursor()
        cur.execute(f'DELETE FROM Login WHERE session_key = "{login_session}"')
        mysql.connection.commit()


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == "POST":
        details = request.form
        username = details['companyUsername']
        password = details['companyPassword']
        cur = mysql.connection.cursor()
        cur.execute(f'SELECT password, id FROM Company WHERE name = "{username}"')
        if cur.rowcount != 0:
            correct_password, company_id = cur.fetchone()
            if password == correct_password:
                cur.close()
                logout_session_company()
                return login_session_company(company_id)
        cur.close()
    return render_template('login.html')


@app.route('/logout')
def logout():
    logout_session_company()
    return redirect('/')


@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == "POST":
        details = request.form
        companyName = details['companyName']
        companyUsername = details['companyUsername']
        companyPassword = details['companyPassword']

        cur = mysql.connection.cursor()
        # Check if company with companyUsername already exists before adding the account
        cur.execute(f'SELECT id FROM Company WHERE email = "{companyUsername}"')
        if cur.rowcount == 0:
            cur.execute("INSERT INTO Company(name, email, password) VALUES (%s, %s, %s)",
                        (companyName, companyUsername, companyPassword))
            mysql.connection.commit()
            cur.execute(f'SELECT id FROM Company WHERE email = "{companyUsername}"')
            company_id = cur.fetchone()[0]
            cur.close()
            return login_session_company(company_id)
        cur.close()
    return render_template('signup.html')


# Route Admin Login
@app.route('/login/admin', methods=['GET', 'POST'])
def login_admin():
    if request.method == "POST":
        details = request.form
        return redirect('/admin')
    return render_template('adminlogin.html')


# Route for Successful Admin Login
@app.route('/admin', methods=['GET', 'POST'])
def admin():
    if get_session_company() == None:
        return redirect('/login')
    # To populate front end
    # Retrieve
    cur = mysql.connection.cursor()
    cur.execute("SELECT * From Company")
    data = cur.fetchall()
    cur.close()

    if request.method == "POST":
        details = request.form
        name = details['companyName']
        email = details['companyEmail']
        password = details['companyPassword']
        requestType = details['type']

        if requestType == 'Add':
            cur = mysql.connection.cursor()
            # query = "INSERT INTO Employee(name = %s, pin = %s, wage = %s, company_id = %s)"
            # cur.execute(query, (name, pin, wage, id))
            cur.execute("INSERT INTO Company(name, email, password) VALUES (%s, %s, %s)",
                        (name, email, password))
            mysql.connection.commit()
            cur.close()
            return redirect('/admin')
        elif requestType == 'Delete':
            cur = mysql.connection.cursor()
            query = "DELETE FROM Company WHERE name = %s"
            cur.execute(query, (name,))
            mysql.connection.commit()
            cur.close()
            return redirect('/admin')
        elif requestType == 'Update':
            cur = mysql.connection.cursor()
            query = "UPDATE Company SET email = %s, password = %s WHERE name = %s"
            cur.execute(query, (email, password, name))
            mysql.connection.commit()
            cur.close()
            return redirect('/admin')
        else:
            return redirect('/admin')

    return render_template('admin.html', result=data, content_type="application/json")


@app.route('/home')
def home():
    if get_session_company() == None:
        return redirect('/login')
    return render_template('home.html')


# We will have to update this query. Right now we are just testing if
# we can populate the frontend with data from our query

@app.route('/employee/timecard', methods=['GET', 'POST'])
def employeetimecard():
    cur = mysql.connection.cursor()
    cur.execute("SELECT * From Time_Card")
    data = cur.fetchall()
    cur.close()

    if request.method == "POST":
        details = request.form

        employeePin = int(details['employeeId'])
        employeeClockIn = details['clockIn']
        employeeClockOut = details['clockOut']
        #military time regex
        miltime = re.compile(r'^([01]\d|2[0-3]):?([0-5]\d)$')
        cur = mysql.connection.cursor()
        res = cur.execute(f'SELECT pin FROM Employee WHERE pin = "{employeePin}"')

        # no pin found
        if res == 0:
            redirect("/employee/timecard")

        # pin found
        if res != 0:
            # inputs not null or empty string
            if employeeClockIn and not employeeClockIn.isspace() and employeeClockOut and not employeeClockOut.isspace():
                # check if input is in military format
                if miltime.match(employeeClockIn) and miltime.match(employeeClockOut):
                    cur.execute(f'SELECT id,company_id From Employee WHERE pin = "{employeePin}"')
                    employeeData = cur.fetchall()
                    employeeId = int(employeeData[0][0])
                    employeeCompanyId = int(employeeData[0][1])

                    today = date.today()
                    #format for sql date format
                    timeCardSubmissionDate = today.strftime("%Y-%m-%d")

                    cur.execute(
                        "INSERT INTO Time_Card(time_in, time_out, employee_id,date,company_id) VALUES (%s, %s, %s, %s, %s)",
                        (employeeClockIn, employeeClockOut, employeeId, timeCardSubmissionDate, employeeCompanyId))
                    mysql.connection.commit()
                    cur.close()
                    return redirect('/employee/timecard')
                else:
                    return redirect('/employee/timecard')


            # the string is non-empty
            else:
                return redirect('/employee/timecard')
    return render_template('employeeTimecard.html', result=data, content_type="application/json")


# Route for Viewing and Adding Reports Working
@app.route('/reports', methods=['GET', 'POST'])
def reports():
    if get_session_company() == None:
        return redirect('/login')
    sessionCompanyId = get_session_company()
    cur = mysql.connection.cursor()
    cur.execute('SELECT * From Report WHERE company_id = %s', (sessionCompanyId,))
    data = cur.fetchall()
    cur.close()
    if request.method == "POST":
        details = request.form
        name = details['employeeName']
        employeeId = details['employeeId']
        startDate = details['startDate']
        endDate = details['endDate']
        cur = mysql.connection.cursor()
        cur.execute('SELECT SUM(time_out - time_in) From Time_Card WHERE employee_id = %s AND date >= %s AND date <= %s'
                    ' AND company_id = %s', (employeeId, startDate, endDate, sessionCompanyId))
        timeCards = cur.fetchall()
        totalHours = int(timeCards[0][0]) / 10000
        cur.execute('INSERT INTO Report(start_date, end_date, hours_worked, employee_id, company_id) VALUES '
                    '(%s, %s, %s, %s, %s)', (startDate, endDate, totalHours, employeeId, sessionCompanyId))
        mysql.connection.commit()
        cur.close()
        cur = mysql.connection.cursor()
        cur.execute('SELECT * From Report WHERE company_id = %s', (sessionCompanyId,))
        allReports = cur.fetchall()
        cur.close()
        return redirect('/reports', result=allReports, content_type="application/json")
    return render_template('reports.html', result=data, content_type="application/json")


# Route for Viewing TimeCards of Report
@app.route('/reports/employee', methods=['GET', 'POST'])
def reportOfEmployee():
    if get_session_company() == None:
        return redirect('/login')
    sessionCompanyId = get_session_company()
    cur = mysql.connection.cursor()
    cur.execute('SELECT * From Employee WHERE company_id = %s', (sessionCompanyId,))
    # cur.execute('SELECT * From Employee')
    data = cur.fetchall()
    cur.close()

    if request.method == "POST":
        details = request.form
        reportId = details['reportId']
        # Find employee id from report
        cur = mysql.connection.cursor()
        cur.execute('SELECT employee_id From Report WHERE id = %s AND company_id = %s', (reportId, sessionCompanyId))
        employee = cur.fetchall()
        cur.close()

        # Get employee wage
        cur = mysql.connection.cursor()
        cur.execute('SELECT wage From Employee WHERE id = %s', (employee,))
        wage = cur.fetchall()
        cur.close()

        # Get hours worked period from the report
        cur = mysql.connection.cursor()
        cur.execute('SELECT hours_worked From Report WHERE id = %s', (reportId,))
        totalHours = cur.fetchall()
        cur.close()

        # Calculate amount
        totalAmount = int(totalHours[0][0]) * int(wage[0][0])

        # Create and Paycheck with amount
        cur = mysql.connection.cursor()
        cur.execute('INSERT INTO Paycheck(amount, employee_wage, report_hours_worked, employee_id, report_id) VALUES '
                    '(%s, %s, %s, %s, %s)', (totalAmount, wage, totalHours, employee, reportId))
        mysql.connection.commit()
        cur.close()

        # Response
        cur = mysql.connection.cursor()
        cur.execute('SELECT * From Paycheck WHERE report_id = %s', (reportId))
        newData = cur.fetchall()
        cur.close()

        return render_template('showPaychecks.html', result=newData, content_type="application/json")
    return render_template('reportOfEmployee.html', result=data, content_type="application/json")


# Add, Delete, and Update employee works
@app.route('/employee/list', methods=['GET', 'POST'])
def employeelist():
    if get_session_company() == None:
        return redirect('/login')
    # To populate front end
    # Retrieve
    cur = mysql.connection.cursor()
    cur.execute("SELECT * From Employee")
    data = cur.fetchall()
    cur.close()

    if request.method == "POST":
        details = request.form
        name = details['employeeName']
        pin = details['employeePin']
        wage = details['employeeWage']
        company_id = details['companyId']
        requestType = details['type']

        if requestType == 'Add':
            cur = mysql.connection.cursor()
            # query = "INSERT INTO Employee(name = %s, pin = %s, wage = %s, company_id = %s)"
            # cur.execute(query, (name, pin, wage, id))
            cur.execute("INSERT INTO Employee(name, pin, wage, company_id) VALUES (%s, %s, %s, %s)",
                        (name, pin, wage, company_id))
            mysql.connection.commit()
            cur.close()
            return redirect('/employee/list')
        elif requestType == 'Delete':
            cur = mysql.connection.cursor()
            query = "DELETE FROM Employee WHERE name = %s"
            cur.execute(query, (name,))
            mysql.connection.commit()
            cur.close()
            return redirect('/employee/list')
        elif requestType == 'Update':
            cur = mysql.connection.cursor()
            query = "UPDATE Employee SET pin = %s, wage = %s, company_id = %s WHERE name = %s"
            cur.execute(query, (pin, wage, company_id, name))
            mysql.connection.commit()
            cur.close()
            return redirect('/employee/list')
        else:
            return redirect('/employee/list')

    return render_template('employeeList.html', result=data, content_type="application/json")


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)

from flask import Flask, render_template, request, redirect, url_for
import mysql.connector
import bcrypt  

from config import DATABASE_CONFIG
app = Flask(__name__)

# MySQL configurations
db = mysql.connector.connect(**DATABASE_CONFIG)
cursor = db.cursor()

# Create a table to store user data if it doesn't exist
create_table_query = """
    CREATE TABLE IF NOT EXISTS user (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255),
        email VARCHAR(255),
        Address TEXT,
        phonenumber VARCHAR(255),
        password VARCHAR(255)
    )
"""
cursor.execute(create_table_query)
db.commit()


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/submit', methods=['POST'])
def submit():
    if request.method == 'POST':
        name = request.form['name']
        email = request.form['email']
        address = request.form['address']
        phonenumber = request.form['phonenumber']
        
        # Hash the password before storing it
        password = request.form['password'].encode('utf-8')  # Get the password from the form
        hashed_password = bcrypt.hashpw(password, bcrypt.gensalt())

        # Insert user data into the database
        insert_query = "INSERT INTO user (name, email, Address, phonenumber, password) VALUES (%s, %s, %s, %s, %s)"
        cursor.execute(insert_query, (name, email, address, phonenumber, hashed_password))
        db.commit()
        
        # Fetch the latest entry
        cursor.execute("SELECT * FROM user ORDER BY id DESC LIMIT 1")
        data = cursor.fetchall()

        return render_template('submitteddata.html', data=data)
    
    return redirect(url_for('index'))



@app.route('/get-data', methods=['GET', 'POST'])
def get_data():
    if request.method == 'POST':
        # Retrieve data based on user input ID
        input_id = request.form['input_id']
        select_query = "SELECT * FROM user WHERE id = %s"
        cursor.execute(select_query, (input_id,))
        data = cursor.fetchall()
        return render_template('data.html', data=data, input_id=input_id)
    return render_template('get_data.html')

@app.route('/delete/<int:id>', methods=['GET', 'POST'])
def delete_data(id):
    if request.method == 'POST':
        # Perform deletion based on the provided ID
        delete_query = "DELETE FROM user WHERE id = %s"
        cursor.execute(delete_query, (id,))
        db.commit()
        return redirect(url_for('get_data'))
    return render_template('delete.html', id=id)


if __name__ == '__main__':
    app.run(debug=True, port=8080, host='0.0.0.0')

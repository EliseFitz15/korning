require 'pg'
require 'csv'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: "korning")
    yield(connection)
  ensure
    connection.close
  end
end

sales_data = CSV.read('sales.csv', headers: true)

  db_connection do |conn|
    sales_data.each do |row|
      product_records = conn.exec_params('SELECT * FROM product WHERE name = $1', [row['product_name']]);
      if product_records.count < 1
        conn.exec_params('INSERT INTO product (name) VALUES ($1)', [row['product_name']]);
      end

      frequency_options = conn.exec_params('SELECT * FROM frequency WHERE invoice_frequency = $1', [row['invoice_frequency']]);
      if frequency_options.count < 1
        conn.exec_params('INSERT INTO frequency (invoice_frequency) VALUES ($1)', [row['invoice_frequency']]);
      end

      employee_data = row['employee'].split(/\((.+)\)/)
      em_name = conn.exec_params('SELECT * FROM employee WHERE name = $1', [employee_data[0]])
      em_email = conn.exec_params('SELECT * FROM employee WHERE email = $1', [employee_data[1]])
      if em_name.count < 1 && em_email.count < 1
        conn.exec_params('INSERT INTO employee (name, email) VALUES ($1, $2)', [employee_data[0], employee_data[1]]);
      end

      customer_data = row['customer_and_account_no'].split(/\((.+)\)/)
      comp = conn.exec_params('SELECT * FROM customer WHERE company_name = $1', [customer_data[0]])
      act_no = conn.exec_params('SELECT * FROM customer WHERE act_no = $1', [customer_data[1]])
      if comp.count < 1 && act_no.count < 1
        conn.exec_params('INSERT INTO customer (company_name, act_no) VALUES ($1, $2)', [customer_data[0], customer_data[1]]);
      end

      frequency_id = conn.exec_params('SELECT id FROM frequency WHERE invoice_frequency = $1', [row['invoice_frequency']]);
      frequency_id = frequency_id[0].values[0]
      product_id = conn.exec_params('SELECT id FROM product WHERE name = $1', [row['product_name']]);
      product_id = product_id[0].values[0]
      employee_id = conn.exec_params("SELECT id FROM employee WHERE name = $1", [employee_data[0]]);
      employee_id = employee_id[0].values[0]
      customer_id = conn.exec_params("SELECT id FROM customer WHERE company_name = $1", [customer_data[0]]);
      customer_id = customer_id[0].values[0]

      conn.exec_params("INSERT INTO sales (
      invoice_no,
      sale_date,
      sale_amount,
      units_sold,
      frequency_id,
      customer_id,
      employee_id,
      product_id
      )
      VALUES($1, $2, $3, $4, $5, $6, $7, $8)",
      [
        row['invoice_no'],
        row['sale_date'],
        row['sale_amount'],
        row['units_sold'],
        frequency_id,
        customer_id,
        employee_id,
        product_id
      ]
      );

    end
  end

ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON * . * TO 'root'@'%' WITH GRANT OPTION;
ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY 'root';
FLUSH PRIVILEGES;

CREATE DATABASE IF NOT EXISTS finalproject_app CHARACTER SET utf8mb4;
CREATE DATABASE IF NOT EXISTS finalproject_erp CHARACTER SET utf8mb4;

CREATE USER IF NOT EXISTS 'app_user'@'%' IDENTIFIED BY 'AppUser@123!';
CREATE USER IF NOT EXISTS 'erp_user'@'%' IDENTIFIED BY 'ErpUser@123!';

GRANT ALL PRIVILEGES ON finalproject_app.* TO 'app_user'@'%';
GRANT ALL PRIVILEGES ON finalproject_erp.* TO 'erp_user'@'%';

FLUSH PRIVILEGES;
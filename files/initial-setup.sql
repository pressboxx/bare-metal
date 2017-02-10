CREATE DATABASE IF NOT EXISTS boxx DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON boxx.* TO 'pressboxx'@'localhost' IDENTIFIED BY 'pressboxx';
GRANT ALL ON boxx.* TO 'pressboxx'@'%' IDENTIFIED BY 'pressboxx';

CREATE DATABASE IF NOT EXISTS example_dev DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
GRANT ALL ON example_dev.* TO 'pressboxx'@'localhost' IDENTIFIED BY 'pressboxx';
GRANT ALL ON example_dev.* TO 'pressboxx'@'%' IDENTIFIED BY 'pressboxx';

FLUSH PRIVILEGES;




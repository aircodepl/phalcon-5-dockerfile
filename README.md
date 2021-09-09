# Phalcon 5 Dockerfile

Here is my Dockerfile to build and install Phalcon 5.x with PSR using docker-compose. 

Composer + MySQL, Memcached and Redis images are included and basic configuration for development purpsoses.

Be sure to adjust component versions to your needs.

PSR/Phalcon installation is based on https://github.com/MilesChou/docker-phalcon/blob/master/7.4/apache/Dockerfile

Dockerfile uses pathetic trick of renaming PSR config file so it's loaded after Phalcon 
(they are loaded in alphabetical order).

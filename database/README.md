# Pre-Requisites

## Docker
---------
Install docker first here: [Docker Website](https://docs.docker.com/engine/install/)

If docker is installed, double check functionality by running this:

`sudo docker run hello-world`

The result must be a 'Hello world' message from docker.


## Database
-----------
Pull the docker image for mysql like this:

`sudo docker pull mysql/mysql-server:tag`

Use the tag for the specific version you want to use or omit the tag and it will automatically download the lastest version.

This version is the community version of mysql and is different from the enterprise edition.

To double check if the image was pulled correctly you can verify by using:

`sudo docker images`

### Run the mysql docker
------------------------

To start a new docker container with MySQL:

`sudo docker run --name=database --restart on-failure -d mysql/mysql-server`

Perform a `sudo docker ps` to find out when the database is started completely. This will become clear if the status is noted a Healthy.

When starting a MySQL DB like this, it will auto generate a one-time password for the user root. You can find the generated password if you use the `sudo docker logs database`

In my case it shows: [Entrypoint] GENERATED ROOT PASSWORD: @e66AAAAAAAAAAAAAKKFJFHFGHGPQ?e4OY_82qc@D+47

### Connect to the MySQL Server from within the Container
---------------------------------------------------------
Once the server is ready, you can run the mysql client within the MySQL Server container you just started, and connect it to the MySQL Server. Use the docker exec -it command to start a mysql client inside the Docker container you have started, like the following:
`sudo docker exec -it database mysql -uroot -p`

Change the one-time password with this command:
`ALTER USER 'root'@'localhost' IDENTIFIED BY '@e66j*ZUsdfsfsdfsdfsdfwerwerrD+48';`

After the reset of the password the server is ready to use and you could try to query the server by issueing the following command: `show databases;`

![show databases](/database/img/database1.png)
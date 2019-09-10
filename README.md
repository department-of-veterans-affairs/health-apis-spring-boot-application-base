# Base-Images
## Building and running app in Docker container
In your terminal of choice, navigate to your ids folder/directory.

Run 

 ```
 mvn clean install
 ```

After a successfull build, navigate to the ids/target/docker directory.

Run the following command to build your docker image.


 ```
./build.sh
 ```

To run the docker image you will need to set several environment variable at runtime.

Run the following command with your credentials

 ```
docker run -e AWS_ACCESS_KEY_ID={YourAccessKeyID} -e AWS_SECRET_ACCESS_KEY={YourSecretAccessKey} -e AWS_DEFAULT_REGION={YourDefaultRegion} -e AWS_BUCKET_NAME={BucketName} --rm -it {your-image-name-of-choice}
 ```
}

At this point, ids should be actively running within your terminal

In a seperate terminal, run the following commands to get your running container ID and jump into that container
 
 ```
docker ps

docker exec -it your-container-id bash
 ```

You can now hit the running app using the second terminal
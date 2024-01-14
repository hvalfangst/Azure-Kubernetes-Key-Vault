# We will use python:3.10-alpine as the base image for building the Flask container
FROM python:3.10-alpine

# It specifies the working directory where the Docker container will run
WORKDIR /app

# Copying all the application files to the working directory
COPY .. .

# Change directory to the location of our newly copied python codebase
WORKDIR /app/python

# Define a build argument for the environment variable
ARG ANIMALS

# Set the environment variable with the build argument
ENV ANIMALS=$ANIMALS

# Install all the dependencies required to run the Flask application
RUN pip install -r requirements.txt

# Run the application using Uvicorn with 8 workers at port 80 as this is what ACI targets
CMD ["uvicorn", "main:api", "--host", "0.0.0.0", "--port", "80"]
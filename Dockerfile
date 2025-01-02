# Use the official Golang image as the base image
FROM golang:1.19-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the Go source code to the working directory
COPY main.go .

# Build the Go application
RUN go mod init myapp && go mod tidy
RUN go build -o myapp

# Expose port 80
EXPOSE 80

# Command to run the application
CMD ["./myapp"]


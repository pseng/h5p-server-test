# Use an official Node.js runtime as the base image
FROM node:20-slim as builder

# Set the working directory in the container
WORKDIR /app

# Copy only the h5p-server's package.json
COPY packages/h5p-server/package.json packages/h5p-server/

# Install dependencies (only for h5p-server)
RUN npm install --workspaces=false packages/h5p-server

# Copy the rest of the application code
COPY packages/h5p-server ./packages/h5p-server
COPY build.sh ./packages/h5p-server/

# Build the h5p-server package
RUN cd packages/h5p-server && sh build.sh

# Stage 2: Production image
FROM node:20-slim

# Set the working directory
WORKDIR /app

# Copy only the built files from the builder stage
COPY --from=builder /app/packages/h5p-server/build /app/build
COPY --from=builder /app/packages/h5p-server/package.json /app/package.json

# Install only production dependencies (only for h5p-server)
RUN npm install --workspaces=false --production packages/h5p-server


# Expose the port that the server will run on (default is often 3000 or 8080)
EXPOSE 3000

# Command to run your application
CMD ["node", "build/src/index.js"]


# Use Nginx to serve static content
FROM nginx:alpine

# Set working directory
WORKDIR /usr/share/nginx/html

# Copy all website files into Nginx html folder
COPY . .

# Expose default HTTP port
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]

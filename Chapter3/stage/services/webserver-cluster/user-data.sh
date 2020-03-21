cat > index.html << EOF
<h1> Hello, World </h1>

<h1> Good night, world </h1>
EOF
nohup busybox httpd -f -p 8080 &
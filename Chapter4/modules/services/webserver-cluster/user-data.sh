cat > index.html << EOF
<h1> Hello, World </h1>
<p>DB address: ${db_address}</p>
<p>DB port: ${db_port}</p>
<h1> Good night, world </h1>
EOF
nohup busybox httpd -f -p ${server_port} &
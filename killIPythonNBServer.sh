#!/bin/bash
#
# Linux tool to kill ipython notebook server on a remote server and
# kill the current SSH tunnel for port forwarding
#
# Anthony Ho, ahho@stanford.edu, 2/20/2015
# Last update 2/20/2015


# Before you run this, you will have set the environmental variable $greendragon as user@greendragon.stanford.edu
# or replace $greendragon below as user@server.stanford.edu
server=peter@greendragon.stanford.edu
remote_port=8889
local_port=8888


# Kill the ipython notebook server on the remote server
ssh $server 'kill $(ps aux | grep -E "$USER.*[i]python.*--port=$remote_port" | awk '\''{print $2}'\'')'

# Kill the SSH tunnel for ipython notebook
kill $(ps aux | grep -E "$USER.*[s]sh -N -f -L localhost:$local_port:localhost:$remote_port" | awk '{print $2}')
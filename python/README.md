# Automation Scripts
---
This is a Python script. Which assumes that there is Mysql server running with reuired tables that exceeded specific dates.

## Here’s what the script does:

1. Selects tables for specific dates.

2. Dumps data from Mysql server running on GKE (Google Kubernetes Engine).

3. Uploads dumped files/tables to the Google cloud storage (Bucket).

4. Once the dumped files/tables uploaded successfully then those tables will be dropped from the Mysql server.


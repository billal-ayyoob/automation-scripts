#!/usr/bin/env python

import sys
import os
import time
import mysql.connector
from itertools import chain
import subprocess
from google.cloud import storage
from zipfile import ZipFile

def dropTable(table_to_be_droped):
    mydb = mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USERNAME"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_DATABASE")
    )

    mycursor = mydb.cursor()
    sql = "DROP TABLE IF EXISTS %s" % table_to_be_droped
    mycursor.execute(sql)
    print("Deleted the table: %s from database" % table_to_be_droped)
    mycursor.close()

def upload_blob(source_file_name):
    """Uploads a file to the bucket."""
    bucket_name = "google-cloud-bucket-name"
    file_to_be_dumped = source_file_name + ".zip"
    destination_blob_name = source_file_name
    storage_credentials_file = "./service-account-json-key-path"
    storage_client = storage.Client.from_service_account_json(storage_credentials_file)
    bucket = storage_client.get_bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)          #ofile is a filename to upload
    blob.upload_from_filename(file_to_be_dumped)   #ofile here is the name of the file inside the bucket


    print(
        "File {} uploaded to {}.".format(
            source_file_name, destination_blob_name
        )
    )
    print("Calling for table %s drop from Database" % source_file_name)
    dropTable(source_file_name)


def getDump(filteredTables):
    host=os.getenv("DB_HOST")
    user = os.getenv("DB_USERNAME")
    password = os.getenv("DB_PASSWORD")
    database = os.getenv("DB_DATABASE")
    for tableToBeDumped in filteredTables:
        if tableToBeDumped !='':
            print(tableToBeDumped)
            print("Dumping required table " + tableToBeDumped)
            try:
                file = open("%s.sql" % tableToBeDumped, 'w')
                proc = subprocess.Popen(["/usr/bin/mysqldump", "--no-tablespaces", "--single-transaction", "--column-statistics=0", "-u" + user, "-p" + password, "-h" + host, database, tableToBeDumped], stdout=file)
                proc.communicate()
                file.close()
                print("Done dumping and started ziping the table: %s" % tableToBeDumped)
                with ZipFile("%s.zip" % tableToBeDumped, "w") as newzip:
                    newzip.write("%s" % tableToBeDumped +".sql")
                print("Done dumping and started uploading %s" % tableToBeDumped)
                upload_blob(tableToBeDumped)
                print("%s is uploaded to the Bucket storage" % tableToBeDumped)
            except subprocess.CalledProcessError as e:
                print("Error: mysqldump ended with status %s, check DB credentials" % e.returncode)
                return False

def getRequiredTablesFromDb():
    mydb = mysql.connector.connect(
        host=os.getenv("DB_HOST"),
        user=os.getenv("DB_USERNAME"),
        password=os.getenv("DB_PASSWORD"),
        database=os.getenv("DB_DATABASE")
    )

    mycursor = mydb.cursor()

    mycursor.execute('SELECT TABLE_NAME FROM INFORMATION_SCHEMA.tables WHERE TABLE_NAME LIKE "%_4475_%" AND CREATE_TIME < (DATE_SUB(CURDATE(), INTERVAL 4 WEEK))')

    myresult = mycursor.fetchall()
    filteredTables = list(chain(*myresult))

    getDump(filteredTables)
    mycursor.close()

if __name__=="__main__":
    getRequiredTablesFromDb()

#!/bin/bash

asadmin delete-jdbc-resource jdbc/ContactsDS
asadmin delete-jdbc-connection-pool ContactsPool

asadmin create-jdbc-connection-pool\
  --datasourceclassname org.postgresql.ds.PGSimpleDataSource\
  --restype javax.sql.DataSource\
  --isconnectvalidatereq=true\
  --validationmethod auto-commit\
  --ping true\
  --property "ServerName=127.0.0.1:User=${USER}:Password=letmein:PortNumber=5432:DatabaseName=${USER}_CONTACTS_DEV" ContactsPool
asadmin create-jdbc-resource --connectionpoolid ContactsPool jdbc/ContactsDS

asadmin set domain.resources.jdbc-connection-pool.ContactsPool.property.JDBC30DataSource=true

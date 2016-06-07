# **********************************************************************
# * 
# *
# * 
# * 
# * 
# *
# * 
# * 
# *
# **********************************************************************

POSTGIS_PGSQL_VERSION=93
Post_Rtree=Post_Rtree_gist
ROOTDIR=/usr/local/posttrajectory
Post_RTree_DIR=$(ROOTDIR)/test/$(Post_Rtree)

# PostgreSQL psql
PSQL = /usr/local/pgsql/bin/psql

# PostgreSQL Directory 
pgsql = /usr/local/pgsql
includedir = /usr/local/pgsql/include
includedir_server = $(includedir)/server
includedir_libpgcommon = ./libpgcommon

# .so Directory
Post_RTree_lib_DIR = $(Post_RTree_DIR)/lib

CC=gcc

# source Files
Post_RTree_O = gserialized_gist_nd.o
Post_RTree_SO = gserialized_gist_nd.so
Post_RTree_SQL = post_RTree_sql.sql
Post_RTree_SQL_uninstall =  post_RTree_sql_uninstall.sql


all: 
	$(CC) -fpic -c gserialized_gist_nd.c -I$(includedir_server) -I$(includedir_libpgcommon)
	$(CC) -c $(includedir_libpgcommon)/gserialized_gist.c -o $(includedir_libpgcommon)/gserialized_gist.o -I$(includedir_server) 
	$(CC) -shared -o $(Post_RTree_SO) $(Post_RTree_O)

clean:
	rm -f $(Post_RTree_O)
	rm -f $(Post_RTree_SO)
	rm -f $(includedir_libpgcommon)/gserialized_gist.o

install: installdirs 
	cp $(Post_RTree_SO) $(Post_RTree_lib_DIR)
	cp $(Post_RTree_SQL) $(Post_RTree_DIR)	
	cp $(Post_RTree_SQL_uninstall) $(Post_RTree_DIR)
	$(PSQL) -U postgres postgres < $(Post_RTree_DIR)/$(Post_RTree_SQL)

installdirs:
	mkdir -p $(Post_RTree_DIR)
	mkdir $(Post_RTree_lib_DIR)

uninstall:   
	$(PSQL) -U postgres postgres < $(Post_RTree_DIR)/$(Post_RTree_SQL_uninstall)
	rm -rf $(Post_RTree_DIR)
	

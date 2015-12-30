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
WTBtree=WTBtree_gist
ROOTDIR=/usr/local/posttrajectory
WTBTree_DIR=$(ROOTDIR)/test/$(WTBtree)

#GeoHash Library
GEOHASHDIR=./geohash

# PostgreSQL psql
PSQL = /usr/local/pgsql/bin/psql

# PostgreSQL Directory 
pgsql = /usr/local/pgsql
includedir = /usr/local/pgsql/include
includedir_server = $(includedir)/server

# .so Directory
trjlibdir = $(WTBTree_DIR)/lib

CC=gcc

# SAIARY Files
WTBtree_O = WTBtree_gist.o
WTBtree_SO = WTBtree_gist.so
WTBtree_SQL = WTBtree_gist.sql
WTBtree_SQL_uninstall =  WTBtree_gist_uninstall.sql


all: geohashLib
	$(CC) -fpic -c WTBtree_gist.c -I$(includedir_server) -I$(GEOHASHDIR)
	$(CC) -shared -o $(WTBtree_SO) $(WTBtree_O)

geohashLib: 
	$(CC) -c $(GEOHASHDIR)/geohash.c -o $(GEOHASHDIR)/geohash.o 
	ar rcs $(GEOHASHDIR)/libgeohash.a $(GEOHASHDIR)/geohash.o
	rm $(GEOHASHDIR)/geohash.o

clean:
	rm -f $(WTBtree_O)
	rm -f $(WTBtree_SO)
	rm -f $(GEOHASHDIR)/libgeohash.a

install: installdirs 
	cp $(WTBtree_SO) $(trjlibdir)
	cp $(WTBtree_SQL) $(WTBTree_DIR)	
	cp $(WTBtree_SQL_uninstall) $(WTBTree_DIR)
	$(PSQL) -U postgres postgres < $(WTBTree_DIR)/$(WTBtree_SQL)

installdirs:
	mkdir -p $(WTBTree_DIR)
	mkdir $(trjlibdir)

uninstall:   
	$(PSQL) -U postgres postgres < $(WTBTree_DIR)/$(WTBtree_SQL_uninstall)
	rm -rf $(WTBTree_DIR)
	

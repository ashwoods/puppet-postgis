#!/bin/sh

TMPL_NAME="template_postgis"
psql -l |grep -q template_postgis && exit

PG_VERSION=$(pg_lsclusters --no-header | awk '{ print $1 }')

case "$PG_VERSION" in
'8.3')
PG_POSTGIS="/usr/share/postgresql-8.3-postgis/lwpostgis.sql"
PG_SPATIAL_REF="/usr/share/postgresql-8.3-postgis/spatial_ref_sys.sql"
;;
'8.4')
PG_POSTGIS="/usr/share/postgresql/8.4/contrib/postgis-1.5/postgis.sql"
PG_SPATIAL_REF="/usr/share/postgresql/8.4/contrib/postgis-1.5/spatial_ref_sys.sql"
;;
'9.0')
PG_POSTGIS="/usr/share/postgresql/9.0/contrib/postgis-1.5/postgis.sql"
PG_SPATIAL_REF="/usr/share/postgresql/9.0/contrib/postgis-1.5/spatial_ref_sys.sql"
;;
'9.1')
PG_POSTGIS="/usr/share/postgresql/9.1/contrib/postgis-1.5/postgis.sql"
PG_SPATIAL_REF="/usr/share/postgresql/9.1/contrib/postgis-1.5/spatial_ref_sys.sql"
esac

cat << EOF | psql -q
CREATE DATABASE $TMPL_NAME WITH template = template1;
UPDATE pg_database SET datistemplate = TRUE WHERE datname = '$TMPL_NAME';
EOF

createlang plpgsql $TMPL_NAME
psql -q -d $TMPL_NAME -f $PG_POSTGIS
psql -q -d $TMPL_NAME -f $PG_SPATIAL_REF

cat << EOF | psql -d $TMPL_NAME
GRANT ALL ON geometry_columns TO PUBLIC;
GRANT SELECT ON spatial_ref_sys TO PUBLIC;
VACUUM FREEZE;
EOF


#! /bin/bash

# This is a very rough script to check consistancy of zebra config files.
# The script assumes that $KOHA_CONF is defined and points to the koha-config.xml
# Usage: $0 [marcflavor]
# If markflavor is not specified, it will default to 'marc21'. 

# Output should look something like this:
# index name: 'ISBN' att: '7'
# ===========================
# ISBN 1=7
#   <index_subfields tag="020" subfields="a">
#     <target_index>ISBN:w</target_index>
# --
#   <index_subfields tag="773" subfields="z">
#     <target_index>ISBN:w</target_index>
# 

# TODO: MARCFLAVOR should be acquired from Koha.
MARCFLAVOR=${1:-'marc21'}

# Sanity checks:

## $KOHA_CONF is populated

if [ -z $KOHA_CONF ]
then
    echo "The shell variable '\$KOHA_CONF' must contain the path to koha-conf.xml. Exiting."
    exit
fi

## Biblio indexing must use DOM.
if xmlstarlet sel -t -v 'yazgfs/config/zebra_bib_index_mode' $KOHA_CONF | grep -qvi 'dom'
then
    echo "Biblio indexing must use DOM."
    exit
fi

ZEBRA_BIBLIOS_DOM="$(xmlstarlet sel -t -v 'yazgfs/server/config' $KOHA_CONF | grep zebra-biblios-dom.cfg | head -1 )"


find_file() {
    for path in $(grep profilePath $1 | cut -d : -f2- | sed "s/:/\n/g"); do find $path ! -type d ; done | grep "$2"
}

underline () 
{ 
    echo "$@" | perl -ne 'chomp; print "\n$_\n"; print "=" x length($_) . "\n" '
}


bib1file=$(find_file $ZEBRA_BIBLIOS_DOM bib1.att)
biblio_koha_indexdefs=$(find_file $ZEBRA_BIBLIOS_DOM "${MARCFLAVOR}.*biblio-koha-indexdefs.xml" )
ccl_properties="$(xmlstarlet sel -t -v 'yazgfs/serverinfo/ccl2rpn' $KOHA_CONF)"

# TODO: include biblio_zebra_indexdefs in the report.

grep '^att' $bib1file | while read placeholder att indexname
do 
    underline "index name: '$indexname' att: '$att'"
    grep "^[^#].*[^,]1=${att}\>" $ccl_properties | sort -u
    egrep "tag=\"|>${indexname}:"  $biblio_koha_indexdefs | grep -B1 ">${indexname}:"
done 


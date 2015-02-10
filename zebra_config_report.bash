#! /bin/bash

# This is a very rough script to check consistancy of zebra config files.
# The script assumes that $KOHA_CONF is defined and points to the koha-config.xml
# Usage: $0 [marcflavor]
# If markflavor is not specified, it will default to 'marc21'. 

# NOTE: the shell variabl3 ccl_properties is currently hard coded to 'koha-dev/etc/zebradb/ccl.properties'
# You will need to change this on a package install.

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

ZEBRA_BIBLIOS_DOM="$(grep zebra-biblios-dom.cfg $KOHA_CONF | sort -u | sed -e 's|[[:space:]]*</*config>||g')"

find_file() {
    for path in $(grep profilePath $1 | cut -d : -f2- | sed "s/:/\n/g"); do find $path ! -type d ; done | grep "$2"
}

underline () 
{ 
    echo "$@" | perl -ne 'chomp; print "\n$_\n"; print "=" x length($_) . "\n" '
}


bib1file=$(find_file $ZEBRA_BIBLIOS_DOM bib1.att)
biblio_koha_indexdefs=$(find_file $ZEBRA_BIBLIOS_DOM "${MARCFLAVOR}.*biblio-koha-indexdefs.xml" )
ccl_properties='koha-dev/etc/zebradb/ccl.properties'

# TODO: ccl_properties can be found using
#    grep 'ccl2rpn' $KOHA_CONF

# TODO: include biblio_zebra_indexdefs in the report.

# TODO: better to use xpath rather than grep for grabbing values from xml files.

grep '^att' $bib1file | while read placeholder att indexname
do 
    underline "index name: '$indexname' att: '$att'"
    grep "^[^#].*[^,]1=${att}\>" $ccl_properties
    egrep "tag=\"|>${indexname}:"  $biblio_koha_indexdefs | grep -B1 ">${indexname}:"
done 


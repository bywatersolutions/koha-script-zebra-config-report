# zebra-config-report
Check bib1 attributes and zebra index names between bib.att, ccl.properties, and biblio_koha_indexdefs.xml

This is a very rough script to check consistancy of zebra config files.
The script assumes that $KOHA_CONF is defined and points to the koha-config.xml

    Usage: $0 [marcflavor]

If markflavor is not specified, it will default to 'marc21'. 

NOTE: the shell variabl3 ccl_properties is currently hard coded to 'koha-dev/etc/zebradb/ccl.properties'
You will need to change this on a package install.

Output should look something like this:

    index name: 'ISBN' att: '7'
    ===========================
    ISBN 1=7
     <index_subfields tag="020" subfields="a">
       <target_index>ISBN:w</target_index>
    --
     <index_subfields tag="773" subfields="z">
       <target_index>ISBN:w</target_index>


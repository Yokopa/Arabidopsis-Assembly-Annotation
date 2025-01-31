Notes:

- R Scripts: Corresponding .sh scripts are provided in case you want to execute them via SLURM on the cluster.

- For 08_parse_repeatmasker_output.sh:
  The parseRM.pl script must be in the same directory as the script.
  If it's missing, the script will automatically download it from https://raw.githubusercontent.com/4ureliek/Parsing-RepeatMasker-Outputs/master/parseRM.pl.

- For 21_refine_gene_annotation.sh:
  The omark.contextualize.py file needs to be in the same directory as the script. You can find this file in the cluster at:
  /data/courses/assembly-annotation-course/CDS_annotation/softwares/OMArk-0.3.0/utils/omark_contextualize.py.

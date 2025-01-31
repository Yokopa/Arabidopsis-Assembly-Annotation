#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   08_parse_repeatmasker_output.sh
#
# DESCRIPTION:
#   This script processes and parses the RepeatMasker output file (`.out`) using 
#   the `parseRM.pl` script. The output, generated from the EDTA pipeline, 
#   contains annotated repetitive sequences from the genome. This script extracts 
#   and organizes the repeat annotations into a more readable and usable format 
#   (e.g., `.tab` files) for downstream analysis.
#
# USAGE:
#   To execute the script, run it using the SLURM job scheduler with the following command:
#     sbatch 08_parse_repeatmasker_output.sh
#
# DEPENDENCIES:
#   - BioPerl: Required for running the `parseRM.pl` script.
#   - parseRM.pl: Perl script that parses RepeatMasker output files.
#
# INPUT:
#   - RepeatMasker output file (`assembly.fasta.mod.out`) generated by the EDTA pipeline.
#
# OUTPUT:
#   - Parsed RepeatMasker results in `.tab` format, saved in `$OUTPUT_DIR`.
#
# NOTE:
#   - Ensure the input file path (`$INPUT_DIR`) and working directory (`$WORKDIR`) are 
#     correctly set.
#================================================================

#SBATCH --cpus-per-task=1
#SBATCH --time=02:00:00
#SBATCH --mem=8G
#SBATCH --job-name=parseRM
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/08_parseRM_output_%j.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_annotation/logs/08_parseRM_error_%j.e
#SBATCH --partition=pibu_el8

# Load BioPerl module required for running the parseRM.pl script
module add BioPerl/1.7.8-GCCcore-10.3.0

# Set working directory
WORKDIR="/data/users/ascarpellini/assembly_annotation_course/genome_annotation"

# Define input directory where RepeatMasker output files are stored
INPUT_DIR="$WORKDIR/outputs/01_edta_TE/assembly.fasta.mod.EDTA.anno"

# --------------------------------------
# Check if the parseRM.pl script is available, and download it if not
pushd "$WORKDIR/scripts"

if [[ ! -f ./parseRM.pl ]]; then
    echo "parseRM.pl script doesn't exist. Download process started"
    
    # Download the parseRM.pl script from GitHub
    wget https://raw.githubusercontent.com/4ureliek/Parsing-RepeatMasker-Outputs/master/parseRM.pl

    # Make the script executable
    chmod +x parseRM.pl

    echo "parseRM.pl script ready to be used"

fi

popd
# --------------------------------------

# Path to parseRM.pl script
PARSERM_SCRIPT=$WORKDIR/scripts/parseRM.pl

# Define output directory for parsed RepeatMasker results
OUTPUT_DIR="$WORKDIR/outputs/08_parsed_repeatmasker"
mkdir -p "$OUTPUT_DIR"

# Run the parseRM.pl script with specified options
perl $PARSERM_SCRIPT -i "$INPUT_DIR//assembly.fasta.mod.out" -l 50,1 -v

# Move the output `.tab` files to the specified output directory
mv $INPUT_DIR/*.tab "$OUTPUT_DIR"

# Inform the user that the output files have been successfully moved
echo echo "Output files moved to $OUTPUT_DIR."
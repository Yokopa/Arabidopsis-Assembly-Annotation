#!/usr/bin/env bash

#================================================================
# SCRIPT NAME: 
#   11-1_find_optimal_kmer.sh
#
# DESCRIPTION: 
#   This script calculates the genome size for genome assemblies 
#   obtained with Flye, Hifiasm, and LJA, then determines the best 
#   k-mer size using the Merqury tool.
#
# USAGE:
#   sbatch 11-1_find_optimal_kmer.sh
# NOTES:
#   - Ensure that input assembly files exist before running this script.
#   - Adjust paths as necessary for your environment.
#================================================================

#SBATCH --time=02:00:00
#SBATCH --mem=32G
#SBATCH --cpus-per-task=8
#SBATCH --job-name=find_optimal_kmer
#SBATCH --mail-user=anna.scarpellinipancrazi@students.unibe.ch
#SBATCH --mail-type=end
#SBATCH --output=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/11-1_find_optimal_kmer_output_%A.o
#SBATCH --error=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly/logs/11-1_find_optimal_kmer_error_%A.e
#SBATCH --partition=pibu_el8

# Set paths
WORKDIR=/data/users/ascarpellini/assembly_annotation_course/genome_transcriptome_assembly # Working directory

# Define assembly paths
ASSEMBLIES=(
    "$WORKDIR/outputs/05_flye/assembly.fasta"
    "$WORKDIR/outputs/06_hifiasm/hifiasm.bp.p_ctg.fa"
    "$WORKDIR/outputs/07_lja/assembly.fasta"
)

# Define the container for Merqury
CONTAINER=/containers/apptainer/merqury_1.3.sif
export MERQURY=/usr/local/share/merqury 

# Define output directory
OUTPUT_DIR=$WORKDIR/outputs/11_merqury/optimal_kmer
mkdir -p $OUTPUT_DIR

# Function to calculate genome size
calculate_genome_size() {
    local assembly=$1
    local size=$(awk '{if(NR%2==0) {total += length($0)}} END {print total}' "$assembly")
    echo $size
}

# Loop through each assembly and calculate genome size
for asm in "${ASSEMBLIES[@]}"; do
    # Check if the assembly file exists
    if [[ -f $asm ]]; then
        echo "Calculating genome size for: $asm"
        genome_size=$(calculate_genome_size "$asm")
        echo "Genome size: $genome_size bases"

        # Determine the appropriate prefix for output
        case "$asm" in
            *"flye"*)
                prefix="flye"
                ;;
            *"hifiasm"*)
                prefix="hifiasm"
                ;;
            *"lja"*)
                prefix="lja"
                ;;
            *)
                echo "Unknown assembly type for $asm"
                continue
                ;;
        esac
        
        # Run best_k.sh with the calculated genome size and output prefix in the container
        echo "Determining best k-mer size..."
        apptainer exec --bind $WORKDIR $CONTAINER sh "$MERQURY/best_k.sh" "$genome_size" > "$OUTPUT_DIR/${prefix}_best_k.txt"

        echo "------------------------------------"
    else
        echo "Assembly file not found: $asm"
    fi
done

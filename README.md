# Arabidopsis-Assembly-Annotation

## The project

This study focuses on Arabidopsis thaliana, a model plant organism in genomics, using three accessions from different regions: Abd-0 (UK), Qar-8a (Lebanon), and Ishikawa (Japan). The goal was to perform de novo genome assembly and annotation using three assemblers: Flye, Hifiasm, and LJA.

The assemblies were evaluated using BUSCO, QUAST, and Merqury. The results showed that:
- Flye provided the best contiguity,
- Hifiasm demonstrated the highest completeness.

Structural variations were observed, particularly in the nucleolus organizer regions of chromosomes 2 and 4, which aligned with known biological variability. Transposable element (TE) annotation identified abundant LTR Gypsy, Copia, and Helitron elements, though predictions for Helitron were cautioned due to potential false positives.

Comparative analysis of gene content showed high core gene conservation, with Abd-0 being genetically closest to the reference genome (TAIR10) compared to Ishikawa and Qar-8a. A limitation of the study was the use of only the Sha accession’s RNA transcript for annotation, suggesting that including more accessions would improve the annotation and provide deeper insights into genetic variation.

Overall, the study emphasizes the importance of quality assessments in de novo assembly and annotation, contributing to the development of the A. thaliana pangenome.

## Repository Structure

The repository is organized as follows:
- 1_scripts_assembly/: Contains scripts for genome and transcriptome assemblies.
- 2_scripts_annotation/: Contains scripts for annotation (note: assembly must be completed first).

## Data 
Raw data used in this study includes:

- Whole genome PacBio HiFi reads from three Arabidopsis thaliana accessions: Abd-0, Ishikawa, and Qar-8a.
- Whole transcriptome Illumina RNA-seq data for the accession Sha.

These datasets are part of a larger collection from the study by Lian et al. (2024), available through EMBL-ENA under the accession number PRJEB62038.

## To run this project
All scripts were executed on the IBU cluster. For R scripts, corresponding .sh scripts are provided to run them via SLURM.
Note: Assembly must be performed before starting the annotation process.

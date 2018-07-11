#! /bin/bash

dx select wgs

for chr in {21..22}; do
    dx run tools/genesis_tests \
	-igenotypefile=genotypes/GDS/1KG_phase3_subset_chr${chr}.gds \
	-inull_model=output/DEMO/nullmodel_outcome.Rda \
	-itest_type=Single \
	-imin_mac=10 \
	-ioutputfilename=sing_cmdLinMult_chr${chr} \
	--destination=output/YOURNAME \
	--instance-type mem2_ssd1_x8 \
	--yes
done
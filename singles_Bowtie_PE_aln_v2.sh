#!/bin/bash
# Usage: nohup singles_Bowtie_PE_aln.v2.sh /raid/Genome_refs/bowtie2_refs/hg19/hg19 150328_SLOpeter.xls /raid/USRdirs/Buenrostro_data/greendragon_raid1/runs_tmp/150327_NS500418_Leuk_Peter_Ava/PeterSLO/ &
# read from command line which files to align
ref=$1 # Reference 
list=$2  # Sample list
dir=$3  # Directory

# help
if [ -z "$dir" ]
then
    echo "This will align a directory of single cells"
    echo "First input is the reference"
    echo "Second input is the sample list"
    echo "Third input is the directory"
    exit
fi

# make fastq dir
mkdir fastqs
mkdir tmp
set -o errexit

# loop through
while read sample
do
    # get data names
    file=`echo $sample | cut -d" " -f1`
    
    # pass if header
    if [ $file != "Name" ]
    then	
        # get files
	echo "Processing: " $file
	p1=`ls $dir/$file"_"*R1*.fastq.gz`
	p2=`echo $p1 | sed 's/R1/R2/g'`
	
	# trim
        trimp1=`basename $p1 | sed 's/.fastq/.trim.fastq/g'`
        trimp2=`basename $p2 | sed 's/.fastq/.trim.fastq/g'`
	if [ -f fastqs/$trimp1 ]
	then
	    echo "Found: " $trimp1 "and" $trimp2
	elif [ -f $dir/$trimp1 ]
	then
	    echo "Found: " $trimp1 "and" $trimp2 " in:" $dir
	    mv $dir/$trimp1 fastqs/; mv $dir/$trimp2 fastqs/
	elif [[ $trimp1 == *.trim.* ]]
	then
	    trimp1=`ls $dir/$file"_"*R1*trim*`; trimp2=`ls $dir/$file"_"*R2*trim*`
	    trimp1=`basename $trimp1`;trimp2=`basename $trimp2`
	    echo "Found: " $trimp1 "and" $trimp2 " in:" $dir
	    mv $dir/$trimp1 fastqs/; mv $dir/$trimp2 fastqs/
	else
	    echo "Trimming: " $p1 "and" $p2
	    pyadapter_trim.py -a $p1 -b $p2
	    mv $trimp1 fastqs/; mv $trimp2 fastqs/
	fi
	
	# make out dir
	if [ -d $file ]
	then
	    echo "Directory exists: " $file
	else
	    mkdir $file
	fi
	
	# align
        out1=$file/`basename $p1 | sed 's/.fastq.gz/.bam/g' | sed 's/_R1//g'`
        out2=$file/`basename $p1 | sed 's/.fastq.gz/.align.log/g' | sed 's/_R1//g'`
	if [ -f $out1 ]
	then
	    echo "Found: " $out1
	else
	    echo "Aligning: " $trimp1 "and" $trimp2
	    (bowtie2 -X2000 -p18 --rg-id $file $ref -1 <(gunzip -c fastqs/$trimp1) -2 <(gunzip -c fastqs/$trimp2) | samtools view -bS - -o $out1) 2>$out2
            #(bowtie2 -3 40 -X2000 -p18 --rg-id $file $ref -1 <(gunzip -c fastqs/$trimp1) -2 <(gunzip -c fastqs/$trimp2) | samtools view -bS - -o $out1) 2>$out2
	fi
	
	# sort
	out3=`echo $out1 | sed 's/.bam/.st/'`
        if [ -f $out3.bam ]
        then
            echo "Found: " $out3.bam
        else
            echo "Sorting: " $out1
            java -jar -Djava.io.tmpdir=`pwd`/tmp /home/wjg/Applications/picard-tools-1.77/SortSam.jar SO=coordinate I=$out1 O=$out3.bam VALIDATION_STRINGENCY=SILENT
	    samtools index $out3.bam
	fi
	
	# remove dups/mito
	out5=$file/`basename $p1 | sed 's/.fastq.gz/.dups.log/g' | sed 's/_R1//g'`
	out6=$out3".rmdup.flt.bam"
	chrs=`samtools view -H $out3.bam | grep chr | cut -f2 | sed 's/SN://g' | grep -v chrM | grep -v Y | awk '{if(length($0)<6)print}'`
	if [ -f $out6 ]
	then
	    echo "Found: " $out6
	else
	    echo "Removing duplicates and unwanted chrs: " $out3.bam
	    samtools view -b -q 30 -f 0x2 $out3.bam -o temp.bam `echo $chrs`
	    java -jar -Djava.io.tmpdir=`pwd`/tmp /home/wjg/Applications/picard-tools-1.77/MarkDuplicates.jar INPUT=temp.bam OUTPUT=$out6 METRICS_FILE=$out5 REMOVE_DUPLICATES=true VALIDATION_STRINGENCY=SILENT
            samtools index $out6
	    rm temp.bam
	fi
	
	# get final quality stats
        out7=$file/`basename $p1 | sed 's/.fastq.gz/.stats.log/g' | sed 's/_R1//g'`
	echo -e "Chromosome\tLength\tProperPairs\tBadPairs:Raw" > $out7
	samtools idxstats $out3.bam >> $out7
	echo -e "Chromosome\tLength\tProperPairs\tBadPairs:Filtered" >> $out7
	samtools idxstats $out6 >> $out7
	
	# get iSize histogram
	out8=`echo $out6 | sed 's/.bam/.hist_data.log/'`
	out9=`echo $out6 | sed 's/.bam/.hist_data.pdf/'`
	if [ -f $out8 ]
	then
	    echo "Found: " $out8
	else
	    # get insert-sizes
	    echo '' > $out8
	    java -jar /home/wjg/Applications/picard-tools-1.77/CollectInsertSizeMetrics.jar VALIDATION_STRINGENCY=SILENT I=$out6 O=$out8 H=$out9 W=1000	
	fi
	
	# make TSS pileup fig
        genome=`basename $ref`
	if [ -f $file/$file.RefSeqTSS ]
        then
            echo "Found: " $file.RefSeqTSS
        else
	    echo "Creating TSS pileup"
            if [ $genome = "hg19" ]; then
                pyMakeVplot.py -a $out6 -b /raid/Downloaded_data/hg19_data/RefSeq_genes/parsed_hg19_RefSeq.bed -e 2000 -p ends -v -u -o $file/$file.RefSeqTSS
            elif [ $genome = "mm10" ]; then
		pyMakeVplot.py -a $out6 -b /raid/Downloaded_data/mm10_data/TSS/refSeqmm10.TSS.bed  -e 2000 -p ends -v -u -o $file/$file.RefSeqTSS
            elif [ $genome = "mm9" ]; then
                pyMakeVplot.py -a $out6 -b /raid/Downloaded_data/mm9_data/TSS/refSeqmm9.TSS.bed -e 2000 -p ends -v -u -o $file/$file.RefSeqTSS
            fi
        fi
    fi
done < <(grep '' $list)

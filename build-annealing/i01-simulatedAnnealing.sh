#!/bin/bash

#PBS -m e
#PBS -M zachary.stichter073@topper.wku.edu
#PBS -j eo
#PBS -t 1-9
#PBS -o ./simulatedAnnealingOutput.log
#PBS -e ./simulatedAnnealingErrors.log
#PBS -N 1F6M-SA-001ts
#PBS -l walltime=48:00:00

#------------------------------------------------------------#
#                                                            #
# Simulated Annealing Protocol Submission Script             #
#                                                            #
#------------------------------------------------------------#

# Notes on PBS Environment variables above:
# -m e mail users on end
# -M xxx@xxxxx.edu email address to notify on job completion
# -j eo join the output file to the error file
# -t 1-3 run the trial in simultaneous triplicate



#------------------------------------------------------------#
#                                                            #
# ToDo:                                                      #
#                                                            #
#------------------------------------------------------------#

# Should be updated to accept args later (possibly from command line; alternatively, can pass through qsub)
# Refactor to include input directory such that input files are in their own directory and script references input files within input directory


#------------------------------------------------------------#
#                                                            #
# User Variable Declarations                                 #
#                                                            #
#------------------------------------------------------------#

# Simulated annealing is a five step process. Step 1 is the basic minimization. Step 2 is the heating protocol. Step 3 is the production MD. Step 4 is the cooling protocol. Step 5 is the production MD post coooling.
# Requires 5 jobs. These should exist in the directory specified by ${path}.
# Requires prmtop and inpcrd files as created by tLEaP. These should exist in the directory specified by ${path}.
# Requires a molecule name. This should be the same as the first four characters of the pdb file.
# Requires a checkpoint file. This could be anything. I have used a file named chk.log in the outputStream directory.
# Sends email to target mail recipient when job completes (recipient must be set in line 4; multiple recipients can be entered by separating addresses with commas.)

path="${PBS_O_HOME}/prepBasics/myData/simulated-annealing/1f6m-r/001timeStep/"
inputDirectory="${path}inputStream/"
firstInput="i02-01_Min.in"
secondInput="i03-02_Heat.in"
thirdInput="i04-03_Prod.in"
fourthInput="i05-04_Cool.in"
fifthInput="i06-05_Prod.in"
moleculeName="1F6M"
chkFile="chk.log"
moleculeRefLocation="${PBS_O_HOME}/prepBasics/tagDock/exactCopy/processedStructures"
bound="u"
leftorright="r"
res_list="1-316"


#------------------------------------------------------------#
#                                                            #
# Private Variable Declarations                              #
#                                                            #
#------------------------------------------------------------#

prmTop="${inputDirectory}${moleculeName}_${leftorright}_${bound}.prmtop"
inpCrd="${inputDirectory}${moleculeName}_${leftorright}_${bound}.inpcrd"
firstJob="${inputDirectory}${firstInput}"
secondJob="${inputDirectory}${secondInput}"
thirdJob="${inputDirectory}${thirdInput}"
fourthJob="${inputDirectory}${fourthInput}"
fifthJob="${inputDirectory}${fifthInput}"
jobName=""
outOut=""
rstOut=""
mdCrdOut=""
mdInfoOut=""
outInc=1
outStep=1
dateCode=$(date "+%Y-%m-%d_%H-%M-%S")
containerDir="${path}outputStream_${dateCode}/"
outDir="${containerDir}${moleculeName}-${PBS_ARRAYID}/"
chkPath=${outDir}${chkFile}
outPath=${outDir}${outInc}
lastPath=${outPath}
lastRst=""
trajDir="${outDir}trajAnalysis"
trajProd1=""
trajProd2=""
trajUnBound="${inputDirectory}${moleculeName}_${leftorright}_u.pdb"
trajBound="${inputDirectory}${moleculeName}_${leftorright}_b.pdb"
rmsd1="${trajDir}/rmsd1-1.in"
rmsd2="${trajDir}/rmsd2-1.in"
rmsd3="${trajDir}/rmsd3-1.in"
rmsd4="${trajDir}/rmsd1-2.in"
rmsd5="${trajDir}/rmsd2-2.in"
rmsd6="${trajDir}/rmsd3-2.in"
inFiles="${trajDir}/inFiles/"
bestFrames="${trajDir}/bestFrames/"


#------------------------------------------------------------#
#                                                            #
# Setting Up                                                 #
#                                                            #
#------------------------------------------------------------#

cd ${path}
mkdir ${containerDir}
mkdir ${outDir}
touch ${chkPath}
echo $"$(date): Changed working directory to:" >> ${chkPath}
pwd >> ${chkPath}
echo $"Beginning simulated annealing" >> ${chkPath}
mkdir "${outPath}"


#------------------------------------------------------------#
#                                                            #
# Submit first job to cluster                                #
#                                                            #
#------------------------------------------------------------#

jobName=${firstJob##*-}
jobName=${jobName%%.*}
outOut="o${outInc}-${jobName}.out"
((outInc++))
rstOut="o${outInc}-${jobName}.rst"
((outInc++))
mdInfoOut="o${outInc}-${jobName}.mdinfo"
((outInc++))
mdCrdOut="o${outInc}-${jobName}.mdcrd"
((outInc++))

echo $"$(date): Submitting job 1" >> ${chkPath}
mpirun sander -O -i ${firstJob} -o ${outPath}/${outOut} -p ${prmTop} -c $inpCrd -r ${outPath}/${rstOut} -inf ${outPath}/${mdInfoOut} -x ${outPath}/${mdCrdOut}

# qsub -N "01_Min" -z "AmberSubmit_1.sh"  
echo $"$(date): Job 1 completed." >> ${chkPath}
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
# echo ${outPath} >> ${chkPath}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# Submit second job to cluster                               #
#                                                            #
#------------------------------------------------------------#

jobName=${secondJob##*-}
jobName=${jobName%%.*}
outOut="o${outInc}-${jobName}.out"
((outInc++))
rstOut="o${outInc}-${jobName}.rst"
((outInc++))
mdInfoOut="o${outInc}-${jobName}.mdinfo"
((outInc++))
mdCrdOut="o${outInc}-${jobName}.mdcrd"
((outInc++))

mkdir ${outPath}
echo $"$(date): Submitting job 2" >> ${chkPath}
mpirun sander -O -i ${secondJob} -o ${outPath}/${outOut} -p ${prmTop} -c ${lastPath}/${lastRst} -r ${outPath}/${rstOut} -x ${outPath}/${mdCrdOut} -inf ${outPath}/${mdInfoOut}

echo $"$(date): Job 2 completed." >> ${chkPath}
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# Submit third job to cluster                                #
#                                                            #
#------------------------------------------------------------#

jobName=${thirdJob##*-}
jobName=${jobName%%.*}
outOut="o${outInc}-${jobName}.out"
((outInc++))
rstOut="o${outInc}-${jobName}.rst"
((outInc++))
mdInfoOut="o${outInc}-${jobName}.mdinfo"
((outInc++))
mdCrdOut="o${outInc}-${jobName}.mdcrd"
((outInc++))


mkdir ${outPath}
echo $"$(date): Submitting job 3" >> ${chkPath}
mpirun sander -O -i ${thirdJob} -o ${outPath}/${outOut} -p ${prmTop} -c ${lastPath}/${lastRst} -r ${outPath}/${rstOut} -x ${outPath}/${mdCrdOut} -inf ${outPath}/${mdInfoOut}

# Save .mdcrd file to a variable for reference later
trajProd1=${outPath}/${mdCrdOut}

echo $"$(date): Job 3 completed." >> "$chkPath"
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# Submit fourth job to cluster                               #
#                                                            #
#------------------------------------------------------------#

jobName=${fourthJob##*-}
jobName=${jobName%%.*}
outOut="o${outInc}-${jobName}.out"
((outInc++))
rstOut="o${outInc}-${jobName}.rst"
((outInc++))
mdInfoOut="o${outInc}-${jobName}.mdinfo"
((outInc++))
mdCrdOut="o${outInc}-${jobName}.mdcrd"
((outInc++))

mkdir ${outPath}
echo $"$(date): Submitting job 4" >> ${chkPath}
mpirun sander -O -i ${fourthJob} -o ${outPath}/${outOut} -p ${prmTop} -c ${lastPath}/${lastRst} -r ${outPath}/${rstOut} -x ${outPath}/${mdCrdOut} -inf ${outPath}/${mdInfoOut}

echo $"$(date): job 4 completed." >> "$chkPath"
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# Submit fifth job to cluster                                #
#                                                            #
#------------------------------------------------------------#

jobName=${fifthJob##*-}
jobName=${jobName%%.*}
outOut="o${outInc}-${jobName}.out"
((outInc++))
rstOut="o${outInc}-${jobName}.rst"
((outInc++))
mdInfoOut="o${outInc}-${jobName}.mdinfo"
((outInc++))
mdCrdOut="o${outInc}-${jobName}.mdcrd"
((outInc))

mkdir ${outPath}
echo $"$(date): Submitting job 5" >> ${chkPath}
mpirun sander -O -i $fifthJob -o ${outPath}/${outOut} -p ${prmTop} -c ${lastPath}/${lastRst} -r ${outPath}/${rstOut} -x ${outPath}/${mdCrdOut} -inf ${outPath}/${mdInfoOut}
trajProd2=${outPath}/${mdCrdOut}

echo $"$(date): Job 5 completed." >> "$chkPath"
outInc=1
lastPath=${outPath}
lastRst=${rstOut}
((outStep++))
outPath=${outDir}${outStep}


#------------------------------------------------------------#
#                                                            #
# cpptraj RMSD Analysis                                      #
#                                                            #
#------------------------------------------------------------# 

# Begin RMSD1 analysis
echo "$(date): Beginning cpptraj analysis. Making directory" >> ${chkPath}
mkdir ${trajDir}
touch ${rmsd1}
echo "parm ${prmTop}" >> ${rmsd1}
echo "trajin ${trajProd1}" >> ${rmsd1}
echo "rmsd ${moleculeName}_l_u_1_ffrmsd out ${trajDir}/rmsd1.agr first mass" >> ${rmsd1}
cp ${rmsd1} ${rmsd4}
sed -i "s|${trajProd1}|${trajProd2}|" ${rmsd4}
sed -i "s|rmsd1.agr|rmsd4.agr|" ${rmsd4}

echo "$(date): Running RMSD analysis 1-1" >> ${chkPath}
cpptraj -i ${rmsd1} >> ${chkPath}
echo "$(date): Running RMSD analysis 1-2" >> ${chkPath}
cpptraj -i ${rmsd4} >> ${chkPath}

# Begin RMSD2 analysis
echo "$(date): Creating RMSD2 input file" >> ${chkPath}
touch ${rmsd2}
echo "parm ${prmTop} [l_u_prmtop]" >> ${rmsd2}
echo "parm ${trajUnBound} [l_u_pdb]" >> ${rmsd2}
echo "trajin ${trajProd1} parm [l_u_prmtop]" >> ${rmsd2}
echo "reference ${trajUnBound} [l_u_rmsd2] parm [l_u_pdb]" >> ${rmsd2}
echo "rmsd ${moleculeName}_l_u_1-ubrmsd :${res_list}@CA out ${trajDir}/rmsd2.agr mass ref [l_u_rmsd2]" >> ${rmsd2}
cp ${rmsd2} ${rmsd5}
sed -i "s|${trajProd1}|${trajProd2}|" ${rmsd5}
sed -i "s|rmsd2.agr|rmsd5.agr|" ${rmsd5}

echo "$(date): Running RMSD analysis 2-1" >> ${chkPath}
cpptraj -i ${rmsd2} >> ${chkPath}
echo "$(date): Running RMSD analysis 2-2" >> ${chkPath}
cpptraj -i ${rmsd5} >> ${chkPath}

# Begin RMSD3 analysis
echo "$(date): Creating RMSD3 input file" >> ${chkPath}
touch ${rmsd3}
echo "parm ${prmTop} [l_u_prmtop]" >> ${rmsd3}
echo "parm ${trajBound} [l_b_pdb]" >> ${rmsd3}
echo "trajin ${trajProd1} parm [l_u_prmtop]" >> ${rmsd3}
echo "reference ${trajBound} [l_b_rmsd3] parm [l_b_pdb]" >> ${rmsd3}
echo "rmsd ${moleculeName}_l_u_3-brmsd :${res_list}@CA out ${trajDir}/rmsd3.agr mass ref [l_b_rmsd3]" >> ${rmsd3}
cp ${rmsd3} ${rmsd6}
sed -i "s|${trajProd1}|${trajProd2}|" ${rmsd6}
sed -i "s|rmsd3.agr|rmsd6.agr|" ${rmsd6}

echo "$(date): Running RMSD analysis 3-1" >> ${chkPath}
cpptraj -i ${rmsd3} >> ${chkPath}
echo "$(date): Running RMSD analysis 3-2" >> ${chkPath}
cpptraj -i ${rmsd6} >> ${chkPath}

# Clean Up
mkdir ${inFiles}
mv ${rmsd1} ${inFiles}
mv ${rmsd2} ${inFiles}
mv ${rmsd3} ${inFiles}
mv ${rmsd4} ${inFiles}
mv ${rmsd5} ${inFiles}
mv ${rmsd6} ${inFiles}

#------------------------------------------------------------#
#                                                            #
# Determine best frames & extract them                       #
#                                                            #
#------------------------------------------------------------#

mkdir ${bestFrames}
for i in {1..6}
do
	`${inputDirectory}RMSDAnalysis.py -i ${trajDir}/rmsd${i}.agr -o ${bestFrames}rmsd${i}.txt -m False`
done


#------------------------------------------------------------#
#                                                            #
# Exit script                                                #
#                                                            #
#------------------------------------------------------------#

echo $"${dateCode}: Script executed successfully. Exiting now." >> "$chkPath"
exit

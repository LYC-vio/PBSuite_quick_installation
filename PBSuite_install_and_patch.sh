#!/bin/bash

#Create environment for PBSuite
conda create -y -n PBSuite python=3.6
source activate PBSuite
pip install networkx==1.11
conda install -y numpy
conda install -y blasr
conda install -y samtools
conda install -y pysam
conda install -y h5py
pip install intervaltree_bio

cd ..

#Download PBSuite
wget http://deb.debian.org/debian/pool/main/p/pbsuite/pbsuite_15.8.24+dfsg.orig.tar.xz
tar -xvf pbsuite_15.8.24+dfsg.orig.tar.xz
rm pbsuite_15.8.24+dfsg.orig.tar.xz  

cd PBSuite_15.8.24/

#cp patches
cp ../PBSuite_quick_installation/patches/*.patch .

#Patch
patch -p0 < fix-syntax-error.patch
patch -p0 < intervaltree-import-statement.patch
patch -p0 < fix-example.patch
patch -p0 < fix-shebang-lines.patch
patch -p0 < blasr-5.patch #blasr-5 interface
patch -p0 < intermediate-reads-files.patch

##py2->py3
patch -p0 < 2to3.patch
patch -p0 < fix_py3.patch

#fix some bugs in the py2->3 process
patch -p0 < 2to3_cleanup1.patch
patch -p0 < 2to3_cleanup2.patch

#Copy configure files
sed -i 's?pathtopbsuite?'`pwd`'?' ../PBSuite_quick_installation/setup.sh
cp ../PBSuite_quick_installation/setup.sh .
sed -i 's?pathtopbsuite?'`pwd`'?' ../PBSuite_quick_installation/Protocol.xml
cp ../PBSuite_quick_installation/Protocol.xml ./docs/jellyExample/
cp ../PBSuite_quick_installation/Jellytest.sh  ./docs/jellyExample/
cp ../PBSuite_quick_installation/workflow.sh ./docs/honeyExample/

chmod 777 ./setup.sh
source ./setup.sh

#Test installation
cd ./docs/jellyExample/

chmod 777 ./Jellytest.sh
echo "Testing PBJelly"
sh ./Jellytest.sh
cd -
cd ./docs/honeyExample/
chmod 777 ./workflow.sh
echo "Testing PBHoney"
sh ./workflow.sh
cd -
echo "Installed in" `pwd`


#Based on https://github.com/MASILab/Synb0-DISCO/

#Implemented by Nathaniel Butterworth at the Sydney Informatics Hub
#Please acknowledge our contribution to your work where appropriate.

#Use ubuntu 16.04 base so we can run on Artemis Centos6 host with Singularity.
#FROM nvidia/cuda:9.0-base-centos6
FROM nvidia/cuda:9.0-base-ubuntu16.04

#Update and install dependencies
RUN apt-get update && \
	apt-get install -y build-essential libxtst6 libxt6 wget unzip git zlib1g-dev python

#RUN yum install -y expat-devel libX11-devel mesa-libGL-devel zlib-devel



# #Install fsl
# RUN echo "deb http://neurodeb.pirsquared.org data main contrib non-free" >> /etc/apt/sources.list.d/neurodebian.sources.list && \
	 # echo "deb http://neurodeb.pirsquared.org trusty main contrib non-free" >> /etc/apt/sources.list.d/neurodebian.sources.list

# # RUN wget -O- http://neuro.debian.net/lists/xenial.cn-bj1.full | tee /etc/apt/sources.list.d/neurodebian.sources.list
# RUN apt-get install -y fsl-5.0-core

# ENV FSLDIR=/usr/lib/fsl/5.0
# ENV FSLOUTPUTTYPE=NIFTI_GZ
# ENV PATH=$PATH:$FSLDIR
# ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$FSLDIR

# RUN echo ". /etc/fsl/5.0/fsl.sh" >> /root/.bashrc

WORKDIR /extra

#COPY fsl /extra/fsl
#RUN tar zxf fsl-6.0.1-sources.tar.gz && \
	#cd fsl 

#ENV FSLDIR=/extra/fsl

#RUN yum groupinstall -y 'Development Tools'
#openblas
#RUN . /extra/fsl/etc/fslconf/fsl.sh &&\
#	cd $FSLDIR && \
#	./build
#	cp -r config/gnu_64-gcc5.4 config/$FSLMACHTYPE &&\
#	./build
# RUN ./build 
# RUN /extra/fsl/etc/fslconf/post_install.sh -f /extra/fsl
# RUN make install && \
	# rm -rf fsl-5.0.0-sources.tar.gz


#COPY fsl-6.0.1-sources.tar.gz /extra/fsl-6.0.1-sources.tar.gz

RUN wget -q http://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py && \
    chmod 775 fslinstaller.py && \
	python fslinstaller.py -d /extra/fsl -V 6.0.3 -q && \
	rm -rf fslinstaller.py



# #Set python 3 as default python
RUN apt-get install -y python3-pip python3-dev
RUN alias python="/usr/bin/python3" && \
	alias pip="/usr/bin/pip3" && \
	echo 'alias python="/usr/bin/python3"' >> /root/.bashrc && \
	echo 'alias pip="/usr/bin/pip3"' >> /root/.bashrc

# #Set up python environment
RUN pip3 install --upgrade pip
RUN pip3 install torch torchvision numpy scipy Pillow dominate

# #Install a newer version of cmake
RUN wget https://github.com/Kitware/CMake/releases/download/v3.13.4/cmake-3.13.4-Linux-x86_64.sh 
RUN yes | sh cmake-3.13.4-Linux-x86_64.sh && \
	rm -rf cmake-3.13.4-Linux-x86_64.sh

# #Install ANTs
RUN git clone https://github.com/ANTsX/ANTs.git && \
	cd ANTs && \
	git checkout a025d042f56561812172a1f6b2ae6848ad914767 && \
	mkdir /extra/ants && \
	cd /extra/ants && \
	/extra/cmake-3.13.4-Linux-x86_64/bin/cmake -c -g /extra/ANTs && \
	make -j 2 && \
	rm -rf /extra/ANTs

ENV ANTSPATH=/extra/ants/bin
ENV PATH=/extra/ants/bin:$PATH

#Install Matlab Runtime
RUN mkdir /mcr-install && \
    mkdir /extra/mcr && \
    cd /mcr-install && \
    wget https://ssd.mathworks.com/supportfiles/downloads/R2018b/deployment_files/R2018b/installers/glnxa64/MCR_R2018b_glnxa64_installer.zip && \
    unzip -q MCR_R2018b_glnxa64_installer.zip && \
    rm -f MCR_R2018b_glnxa64_installer.zip && \
    ./install -destinationFolder /extra/mcr -agreeToLicense yes -mode silent && \
    cd / && \
    rm -rf mcr-install

ENV LD_LIBRARY_PATH /extra/mcr/v93/runtime/glnxa64:/extra/mcr/v93/bin/glnxa64:/extra/mcr/v93/sys/os/glnxa64
ENV XAPPLRESDIR /extra/mcr/v93/X11/app-defaults


# #Install Freesufer
WORKDIR /extra
RUN wget -qO- https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.0/freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.0.tar.gz | \
    tar zx -C /extra \
    --exclude='freesurfer/trctrain' \
    --exclude='freesurfer/subjects/fsaverage_sym' \
    --exclude='freesurfer/subjects/fsaverage3' \
    --exclude='freesurfer/subjects/fsaverage4' \
    --exclude='freesurfer/subjects/fsaverage5' \
    --exclude='freesurfer/subjects/fsaverage6' \
    --exclude='freesurfer/subjects/cvs_avg35' \
    --exclude='freesurfer/subjects/cvs_avg35_inMNI152' \
    --exclude='freesurfer/subjects/bert' \
    --exclude='freesurfer/subjects/V1_average' \
    --exclude='freesurfer/average/mult-comp-cor' \
    --exclude='freesurfer/lib/cuda' \
    --exclude='freesurfer/lib/qt'

# # #Install Synb0-DISCO, https://github.com/MASILab/Synb0-DISCO
RUN mkdir /INPUTS && \
	mkdir /OUTPUTS

RUN git clone https://github.com/MASILab/Synb0-DISCO.git

RUN wget https://sourceforge.net/projects/c3d/files/c3d/1.0.0/c3d-1.0.0-Linux-x86_64.tar.gz &&\
	tar -xzvf c3d-1.0.0-Linux-x86_64.tar.gz
	
ENV ANTSPATH=/extra/ants/ANTS-build/Examples
ENV PATH=/extra/ants/ANTS-build/Examples:$PATH
ENV PATH=$PATH:/extra/freesurfer/mni/bin/:/extra/freesurfer/bin/
ENV PATH=$PATH:/extra/c3d-1.0.0-Linux-x86_64/bin
ENV PATH=$PATH:/extra/Synb0-DISCO/data_processing
ENV MNI_DIR=/extra/freesurfer/mni
ENV FREESURFER_HOME=/extra/freesurfer

# #COPY license.txt /extras/freesurfer/license.txt
# #Call with file name
# #Set up for Singularity on Artemis 

RUN git clone https://github.com/ANTsX/ANTs.git && \
	cd ANTs &&\
	git checkout a025d042f56561812172a1f6b2ae6848ad914767

# RUN apt-get install -y software-properties-common python-software-properties
# RUN add-apt-repository -y ppa:deadsnakes/ppa
# RUN apt-get install python3.6

RUN mkdir /project && \
	mkdir /scratch && \
	mv /extra/Synb0-DISCO/atlases/ /extra/atlases && \
	mkdir -p /extra/ANTS/bin/ants/bin/ && \
	mkdir -p /extra/ANTS/ANTs/Scripts && \
	rsync --exclude=*.cxx --exclude=*.a /extra/ants/ANTS-build/Examples/* /extra/ANTS/bin/ants/bin/ && \
	cp /extra/ants/ITKv5-build/bin/* /extra/ANTS/bin/ants/bin/ && \
	cp /extra/ANTs/Scripts/* /extra/ANTS/ANTs/Scripts
	
RUN apt-get install -y tcsh
RUN apt-get install -y dos2unix
RUN dos2unix /extra/Synb0-DISCO/src/pipeline.sh
RUN apt-get install -y bc




CMD ["/bin/bash", "/extra/Synb0-DISCO/src/pipeline.sh"]
#docker run -it --rm -v C:\WORK\ShortProjects\syn\INPUTS\:/INPUTS -v C:\WORK\ShortProjects\syn\build\license.txt:/extra/freesurfer/license.txt syn /bin/bash
#prepare_input.sh /INPUTS/INPUTS/b0.nii.gz /INPUTS/INPUTS/T1.nii.gz /extra/Synb0-DISCO/atlases/mni_icbm152_t1_tal_nlin_asym_09c.nii.gz /extra/Synb0-DISCO/atlases/mni_icbm152_t1_tal_nlin_asym_09c_2_5.nii.gz /OUTPUTS

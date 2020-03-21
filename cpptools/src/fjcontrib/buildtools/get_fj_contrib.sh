#!/bin/bash

srcdir=${1}
wdir=${2}
if [ ! -z ${wdir} ]; then
	[ ! -d ${wdir} ] && mkdir -p ${wdir}
fi

fjcontrib_version=1.042
[ ! -z ${3} ] && fjcontrib_version=${3}

if [ -d ${srcdir} ]; then
	if [ -d ${wdir} ]; then
		cd ${wdir}
		[ ! -e fjcontrib-${fjcontrib_version}.tar.gz ] && wget http://fastjet.hepforge.org/contrib/downloads/fjcontrib-${fjcontrib_version}.tar.gz
		cd -
		if [ -e ${wdir}/fjcontrib-${fjcontrib_version}.tar.gz ]; then
			if [ ! -d ${srcdir}/fjcontrib-${fjcontrib_version}/RecursiveTools ]; then
				cd ${srcdir}
				tar zxvf ${wdir}/fjcontrib-${fjcontrib_version}.tar.gz fjcontrib-${fjcontrib_version}/RecursiveTools
				rm fjcontrib-${fjcontrib_version}/RecursiveTools/example_*.cc
				patch fjcontrib-${fjcontrib_version}/RecursiveTools/RecursiveSymmetryCutBase.hh -i ${srcdir}/patches/RecursiveSymmetryCutBase.patch
			fi
			if [ -d ${srcdir}/fjcontrib-${fjcontrib_version}/RecursiveTools ]; then
				cp -v ${srcdir}/custom/Util.* ${srcdir}/fjcontrib-${fjcontrib_version}/RecursiveTools
			fi

			if [ ! -d ${srcdir}/fjcontrib-${fjcontrib_version}/LundPlane ]; then
				cd ${srcdir}
				tar zxvf ${wdir}/fjcontrib-${fjcontrib_version}.tar.gz fjcontrib-${fjcontrib_version}/LundPlane
				rm fjcontrib-${fjcontrib_version}/LundPlane/example_*.cc
				patch fjcontrib-${fjcontrib_version}/LundPlane/SecondaryLund.hh -i ${srcdir}/patches/SecondaryLund.patch
				patch fjcontrib-${fjcontrib_version}/LundPlane/LundGenerator.hh -i ${srcdir}/patches/LundGenerator.patch
			fi
			if [ -d ${srcdir}/fjcontrib-${fjcontrib_version}/LundPlane ]; then
				cp -v ${srcdir}/custom/DynamicalGroomer.* ${srcdir}/fjcontrib-${fjcontrib_version}/LundPlane
			fi

			if [ ! -d ${srcdir}/fjcontrib-${fjcontrib_version}/ConstituentSubtractor ]; then
				cd ${srcdir}
				tar zxvf ${wdir}/fjcontrib-${fjcontrib_version}.tar.gz fjcontrib-${fjcontrib_version}/ConstituentSubtractor
				rm fjcontrib-${fjcontrib_version}/ConstituentSubtractor/example_*.cc
			fi

		fi
	fi
fi

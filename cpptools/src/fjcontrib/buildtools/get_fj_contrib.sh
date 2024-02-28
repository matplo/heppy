#!/bin/bash

srcdir=${1}
wdir=${2}
if [ ! -z ${wdir} ]; then
	[ ! -d ${wdir} ] && mkdir -p ${wdir}
fi

fjcontrib_version=1.053
[ ! -z ${3} ] && fjcontrib_version=${3}

if [ -d ${srcdir} ]; then
	if [ -d ${wdir} ]; then
		cd ${wdir}
		[ ! -e fjcontrib-${fjcontrib_version}.tar.gz ] && wget http://fastjet.hepforge.org/contrib/downloads/fjcontrib-${fjcontrib_version}.tar.gz --no-check-certificate
		cd -
		if [ -e ${wdir}/fjcontrib-${fjcontrib_version}.tar.gz ]; then
			# RecursiveTools
			if [ ! -d ${srcdir}/fjcontrib-${fjcontrib_version}/RecursiveTools ]; then
				cd ${srcdir}
				tar zxvf ${wdir}/fjcontrib-${fjcontrib_version}.tar.gz fjcontrib-${fjcontrib_version}/RecursiveTools --warning=no-unknown-keyword
				rm fjcontrib-${fjcontrib_version}/RecursiveTools/example_*.cc
				patch fjcontrib-${fjcontrib_version}/RecursiveTools/RecursiveSymmetryCutBase.hh -i ${srcdir}/patches/RecursiveSymmetryCutBase.patch
			fi
			if [ -d ${srcdir}/fjcontrib-${fjcontrib_version}/RecursiveTools ]; then
				cp -v ${srcdir}/custom/Util.* ${srcdir}/fjcontrib-${fjcontrib_version}/RecursiveTools
			fi

			# LundPlane
			if [ ! -d ${srcdir}/fjcontrib-${fjcontrib_version}/LundPlane ]; then
				cd ${srcdir}
				tar zxvf ${wdir}/fjcontrib-${fjcontrib_version}.tar.gz fjcontrib-${fjcontrib_version}/LundPlane --warning=no-unknown-keyword
				rm fjcontrib-${fjcontrib_version}/LundPlane/example_*.cc
				patch fjcontrib-${fjcontrib_version}/LundPlane/SecondaryLund.hh -i ${srcdir}/patches/SecondaryLund.patch
				patch fjcontrib-${fjcontrib_version}/LundPlane/LundGenerator.hh -i ${srcdir}/patches/LundGenerator.patch
			fi
			if [ -d ${srcdir}/fjcontrib-${fjcontrib_version}/LundPlane ]; then
				cp -v ${srcdir}/custom/DynamicalGroomer.* ${srcdir}/fjcontrib-${fjcontrib_version}/LundPlane
				cp -v ${srcdir}/custom/GroomerShop.* ${srcdir}/fjcontrib-${fjcontrib_version}/LundPlane
				# cp -v ${srcdir}/custom/GroomerShopUI.* ${srcdir}/fjcontrib-${fjcontrib_version}/LundPlane
			fi

			# ConstituentSubtractor
			if [ ! -d ${srcdir}/fjcontrib-${fjcontrib_version}/ConstituentSubtractor ]; then
				cd ${srcdir}
				tar zxvf ${wdir}/fjcontrib-${fjcontrib_version}.tar.gz fjcontrib-${fjcontrib_version}/ConstituentSubtractor --warning=no-unknown-keyword
				rm fjcontrib-${fjcontrib_version}/ConstituentSubtractor/example_*.cc
			fi

			# Nsubjettiness
			if [ ! -d ${srcdir}/fjcontrib-${fjcontrib_version}/Nsubjettiness ]; then
				cd ${srcdir}
				tar zxvf ${wdir}/fjcontrib-${fjcontrib_version}.tar.gz fjcontrib-${fjcontrib_version}/Nsubjettiness --warning=no-unknown-keyword
				rm fjcontrib-${fjcontrib_version}/Nsubjettiness/example_*.cc
				patch fjcontrib-${fjcontrib_version}/Nsubjettiness/MeasureDefinition.hh -i ${srcdir}/patches/MeasureDefinition.patch
				patch fjcontrib-${fjcontrib_version}/Nsubjettiness/AxesDefinition.hh -i ${srcdir}/patches/AxesDefinition.patch
			fi

            rm fjcontrib-${fjcontrib_version}/.[!.]* fjcontrib-${fjcontrib_version}/*/.[!.]*  # Remove unnecessary dotfiles

		fi
	fi
fi

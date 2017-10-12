#!/bin/bash

if [[ -z $1 ]];then
	echo "Runtime version required"
	exit 1
fi

FOLDER=Font-11

if [[ -z $2 ]];then
	echo "Font must be specified"
	exit 1
fi

if [[ ! -f "${FOLDER}/${2}" ]];then
	echo "Font not found"
	exit 1
fi

FONT="${2}"
UNDERSCORE=0

EL_RUNTIME_ROOT=/Library/Developer/CoreSimulator/Profiles/Runtimes/iOS\ ${1}.simruntime/Contents/Resources/RuntimeRoot

if (( $(echo "$1 >= 8.2" | bc -l) ));then
	LOCATION="Core"
	if (( $(echo "$1 == 8.2" | bc -l) ));then
		UNDERSCORE=1
	fi
else
	LOCATION="Cache"
fi

TOUCH="${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/installed"
TTF_2X="${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/AppleColorEmoji@2x.ttf"
TTF_2X_="${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/AppleColorEmoji_2x.ttf"
CCF_2X="${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/AppleColorEmoji@2x.ccf"
TTC_2X="${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/AppleColorEmoji@2x.ttc"
TTF="${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/AppleColorEmoji.ttf"
TTF_="${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/AppleColorEmoji_1x.ttf"
CCF="${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/AppleColorEmoji.ccf"
TTC="${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/AppleColorEmoji.ttc"

if [[ ! -f "${TOUCH}" ]];then
	[[ -f "${TTC_2X}" ]] && sudo cp -v "${TTC_2X}" "${TTC_2X/.ttc/.ttc.bak}"
	[[ -f "${TTF_2X}" ]] && sudo cp -v "${TTF_2X}" "${TTF_2X/.ttf/.ttf.bak}"
	[[ -f "${CCF_2X}" ]] && sudo cp -v "${CCF_2X}" "${CCF_2X/.ccf/.ccf.bak}"
	[[ -f "${TTF_2X_}" ]] && sudo cp -v "${TTF_2X_}" "${TTF_2X_/.ttf/.ttf.bak}"
	[[ -f "${TTC}" ]] && sudo cp -v "${TTC}" "${TTC/.ttc/.ttc.bak}"
	[[ -f "${TTF}" ]] && sudo cp -v "${TTF}" "${TTF/.ttf/.ttf.bak}"
	[[ -f "${TTF_}" ]] && sudo cp -v "${TTF_}" "${TTF_/.ttf/.ttf.bak}"
	[[ -f "${CCF}" ]] && sudo cp -v "${CCF}" "${CCF/.ccf/.ccf.bak}"
	if (( $(echo "$UNDERSCORE == 1" | bc -l) ));then
		FONT_="${FONT/@/_}"
		sudo cp -v "${PWD}/${FOLDER}/${FONT}" "${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/${FONT_}"
		sudo cp -v "${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/${FONT_}" "${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/${FONT_/2x/1x}"
	else
		sudo cp -v "${PWD}/${FOLDER}/${FONT}" "${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/"
		sudo cp -v "${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/${FONT}" "${EL_RUNTIME_ROOT}/System/Library/Fonts/${LOCATION}/${FONT/2x/1x}"
	fi
	sudo touch "${TOUCH}"
fi

# ./copyResource.sh <version> AppleColorEmoji@2x.ttf

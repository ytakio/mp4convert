#!/bin/bash -x

INPUT='*'
CODEC='-c copy -c:a libfdk_aac -c:v libx264'
PROFILE='high'
PRESET='medium'
TUNE='animation'
CRF='22'
FLAGS='-movflags +faststart'
OUTPUT='mp4'
TMP='/tmp/mp4convert'
THREADS=$(cat /proc/cpuinfo | grep processor | wc -l)
FILTER='-vf format=yuv420p'

print_help()
{
	echo "usage:
		i)	INPUT='$INPUT'
		f)	INPUT='*.$INPUT'
		v)	FILTER='$FILTER'
		c)	CODEC='$CODEC'
		p)	PROFILE='$PROFILE'
		s)	PRESET='$PRESET'
		t)	TUNE='$TUNE'
		q)	CRF='$CRF'
		o)	OUTPUT='$OUTPUT'
		x)	TXFORMAT='$TXFORMAT'
	"
}

while getopts i:e:f:c:p:s:t:q:o:x: OPT
do
	case $OPT in
		i)	INPUT="$OPTARG";;
		f)	INPUT="*.$OPTARG";;
		v)	FILTER="-vf $OPTARG";;
		c)	CODEC="$OPTARG";;
		p)	PROFILE="$OPTARG";;
		s)	PRESET="$OPTARG";;
		t)	TUNE="$OPTARG";;
		q)	CRF="$OPTARG";;
		o)	OUTPUT="$OPTARG";;
		x)	TXFORMAT="$OPTARG";;
		?)	print_help; exit 2;;
	esac
done

mkdir -p $OUTPUT
mkdir -p $TMP

if [[ -n "${TXFORMAT}" ]]; then
	OUTPUT="${TXFORMAT}"
fi

for file in $INPUT
do
	if [[ -f "${file}" ]]; then
		TARGET="${file%.*}.${OUTPUT}"
		if [[ -n "${TXFORMAT}" ]]; then
			ffmpeg -y -i "${file}" -c copy "${TMP}/${TARGET}"
		else
			ffmpeg -y -i "${file}" -threads ${THREADS} -fps_mode vfr ${FILTER} ${CODEC} -profile:v ${PROFILE} -preset ${PRESET} -tune ${TUNE} -crf ${CRF} ${FLAGS} "${TMP}/${TARGET}"
		fi
		mv "${TMP}/$TARGET" "${OUTPUT}/" &
	fi
done


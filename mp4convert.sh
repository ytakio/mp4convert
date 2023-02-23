#!/bin/bash -x

INPUT=( * )
ACODEC='-c:a libfdk_aac -vbr 5'
VCODEC='-c:v libx264 -profile:v high'
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
		e)	INPUT='*.$INPUT'
		f)	FILTER='$FILTER'
		a)	ACODEC='$ACODEC'
		v)	VCODEC='$VCODEC'
		p)	PRESET='$PRESET'
		t)	TUNE='$TUNE'
		q)	CRF='$CRF'
		o)	OUTPUT='$OUTPUT'
		x)	TXFORMAT='$TXFORMAT'
	"
}

while getopts i:e:f:a:v:p:t:q:o:x:m OPT
do
	case $OPT in
		i)	INPUT=( "$OPTARG" );;
		e)	INPUT=( *.$OPTARG );;
		f)	FILTER="$OPTARG";;
		a)	ACODEC="$OPTARG";;
		v)	VCODEC="$OPTARG";;
		p)	PRESET="$OPTARG";;
		t)	TUNE="$OPTARG";;
		q)	CRF="$OPTARG";;
		o)	OUTPUT="$OPTARG";;
		x)	TXFORMAT="$OPTARG";;
		m)	OUTPUT="m4a";;
		?)	print_help; exit 2;;
	esac
done

mkdir -p $OUTPUT
mkdir -p $TMP

if [[ -n "${TXFORMAT}" ]]; then
	OUTPUT="${TXFORMAT}"
elif [ "${OUTPUT}" == "m4a" ]; then
	VCODEC=''
	FILTER=''
	ACODEC='-c:a libfdk_aac -vbr 5'
fi


for file in "${INPUT[@]}";
do
	if [[ -f "${file}" ]]; then
		TARGET="${file%.*}.${OUTPUT}"
		if [[ -n "${TXFORMAT}" ]]; then
			ffmpeg -y -i "${file}" -c copy "${TMP}/${TARGET}"
		else
			ffmpeg -y -i "${file}" -threads ${THREADS} -fps_mode vfr ${FILTER} -c copy ${ACODEC} ${VCODEC} -preset ${PRESET} -tune ${TUNE} -crf ${CRF} ${FLAGS} "${TMP}/${TARGET}"
		fi
		mv "${TMP}/$TARGET" "${OUTPUT}/" &
	fi
done


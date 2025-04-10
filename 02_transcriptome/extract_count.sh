while read line
do
python3 extract_counts.py ${line}.txt ${line}_count1.txt
cat ${line}_count1.txt|sort > ${line}_count.txt
done < RIL_RS_id.list


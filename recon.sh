#!/bin/bash


url=$1

#creates folders for the target
if [ ! -z "$url" ] && [ ! -d "$url" ];then
	mkdir "$url"
elif [ -z "$url" ];then
	echo "Domain is required as an arguement."
	exit
fi

recon_directory_timestamp="recon_$(date +%s000)"
if [ ! -d "$url/$recon_directory_timestamp" ];then
	mkdir "$url/$recon_directory_timestamp"
fi

#runs assetfinder then appends the information to a text file called final.txt
echo "[+] Harvesting subdomains..."
assetfinder $url >> $url/$recon_directory_timestamp/assets.txt
cat $url/$recon_directory_timestamp/assets.txt | grep $1 >> $url/$recon_directory_timestamp/final.txt
rm $url/$recon_directory_timestamp/assets.txt

#runs amass and appends the results to the same final.txt file
echo "[+] Still harvesting..."
amass enum -d $url >> $url/$recon_directory_timestamp/f.txt
sort -u $url/$recon_directory_timestamp/f.txt >> $url/$recon_directory_timestamp/final.txt
rm $url/$recon_directory_timestamp/f.txt

#runs httprobe against the list and creates another list of alive domains called alive.txt
echo "[+] Probing for alive hosts..."
cat $url/$recon_directory_timestamp/final.txt | sort -u | uniq -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' >> $url/$recon_directory_timestamp/alive.txt

echo "[+] Done!"

#once complete there will be two files in the recon folder. The two are alive.txt with domains up and final.txt with ALL domains. 

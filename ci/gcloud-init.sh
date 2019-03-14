#!/bin/bash -e

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
names_first=(`jq -r '.unicorn.first[]' ${script_dir}/names.json`)
names_middle=(`jq -r '.unicorn.middle[]' ${script_dir}/names.json`)
names_last=(`jq -r '.unicorn.last[]' ${script_dir}/names.json`)

zone_uri_list=(`gcloud compute zones list --uri --filter="name~'^(us|europe)-.*$'"`)
zone_name_list=("${zone_uri_list[@]##*/}")
zone_name_list_shuffled=( $(shuf -e "${zone_name_list[@]}") )

accessToken=`cat ~/.accessToken`
livelogSecret=`cat ~/.livelogSecret`
livelogcrt=`cat ~/.livelog.crt`
livelogkey=`cat ~/.livelog.key`
pgpKey=`cat ~/.ssh/occ-secrets-private.key`
gwConfig="`curl -s https://raw.githubusercontent.com/mozilla-releng/OpenCloudConfig/gamma/userdata/Manifest/gecko-1-b-win2012-gamma.json | jq --arg accessToken ${accessToken} --arg livelogSecret ${livelogSecret} -c '.ProvisionerConfiguration.userData.genericWorker.config | .accessToken = $accessToken | .livelogSecret = $livelogSecret' | sed 's/\"/\\\"/g'`"

for zone_name in ${zone_name_list[@]}; do
  # generate a random instance name which does not pre-exist
  existing_instance_uri_list=(`gcloud compute instances list --uri`)
  existing_instance_name_list=("${existing_instance_uri_list[@]##*/}")
  instance_name=${names_first[$[$RANDOM % ${#names_first[@]}]]}-${names_middle[$[$RANDOM % ${#names_middle[@]}]]}-${names_last[$[$RANDOM % ${#names_last[@]}]]}
  while [[ " ${existing_instance_name_list[@]} " =~ " ${instance_name} " ]]; do
    instance_name=${names_first[$[$RANDOM % ${#names_first[@]}]]}-${names_middle[$[$RANDOM % ${#names_middle[@]}]]}-${names_last[$[$RANDOM % ${#names_last[@]}]]}
  done
  echo "spawning ${instance_name} in ${zone_name}"
  gcloud compute instances create ${instance_name} \
    --image-project windows-cloud \
    --image-family windows-2012-r2 \
    --machine-type n1-standard-8 \
    --boot-disk-size 120 \
    --boot-disk-type pd-ssd \
    --scopes storage-ro \
    --metadata "^;^windows-startup-script-url=gs://open-cloud-config/gcloud-startup.ps1;workerType=gecko-1-b-win2012-gamma;sourceOrg=mozilla-releng;sourceRepo=OpenCloudConfig;sourceRevision=gamma;gwConfig=${gwConfig};pgpKey=${pgpKey};livelogkey=${livelogkey};livelogcrt=${livelogcrt}" \
    --zone ${zone_name}
  gcloud beta compute disks create ${instance_name}-disk-1 --size 120 --type pd-ssd --physical-block-size 4096 --zone ${zone_name}
  gcloud compute instances attach-disk ${instance_name} --disk ${instance_name}-disk-1 --zone ${zone_name}
done

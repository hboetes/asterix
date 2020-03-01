#!/bin/bash
# Copyright 2020
# Han Boetes <hboetes@gmail.com>
# This script generates a csv file which you can bulk import with FreePBX and a qr-code file.
# With the csv you can set up a working extension with a secure password
# The qr-code the user can use to set up sipnetic
# I've set up a new working softphone on android in less than a minute.

server="sip.example.com"
ext="$1"
name="$2"
wrong="$3"

re='^[0-9]{3,4}$'
if ! [[ $ext =~ $re ]] ; then
    echo "$0: error: Not a valid extension." >&2
    exit 1
fi

if [[ $name == '' ]]; then
    echo "$0: error: That name is too short." >&2
    exit 1
fi

if [[ $wrong != '' ]]; then
    echo "$0: error: Put the name in single quotes, like this: 'Firstname Lastname'" >&2
    exit 1
fi

# echo "$0 '$ext' '$name'"
# exit 0

password="$(< /dev/urandom tr -dc "[:alnum:]" | dd count=1 bs=16 2> /dev/null)"
mkdir $ext
cd $ext
qrencode -o $ext.png "n=${name};u=${ext};d=${server};p=$password;"

cat << EOF > $ext.csv
extension,password,name,voicemail,ringtimer,noanswer,recording,outboundcid,sipname,noanswer_cid,busy_cid,chanunavail_cid,noanswer_dest,busy_dest,chanunavail_dest,mohclass,id,tech,dial,devicetype,user,description,emergency_cid,hint_override,cwtone,recording_in_external,recording_out_external,recording_in_internal,recording_out_internal,recording_ondemand,recording_priority,answermode,intercom,cid_masquerade,concurrency_limit,1,pin,2,label,3,4,lcontext,5,incominglimit,6,directed_pickup_context,7,directed_pickup,8,pickup_modeanswer,9,namedcallgroup,10,namedpickupgroup,11,transfer,12,echocancel,13,language,14,callerid,15,cid_num,16,17,mailbox,18,musicclass,19,allow,20,disallow,21,videomode,22,dnd,23,silencesuppression,24,secondary_dialtone_digits,25,secondary_dialtone_tone,26,accountcode,aggregate_mwi,avpf,context,defaultuser,device_state_busy_at,direct_media,dtmfmode,force_rport,icesupport,match,max_contacts,maximum_expiration,media_encryption,media_encryption_optimistic,media_use_received_transport,message_context,minimum_expiration,mwi_subscription,outbound_proxy,qualifyfreq,refer_blind_progress,rewrite_contact,rtcp_mux,rtp_symmetric,rtp_timeout,rtp_timeout_hold,secret,send_connected_line,sendrpid,sipdriver,timers,timers_min_se,transport,trustrpid,callwaiting_enable,findmefollow_strategy,findmefollow_grptime,findmefollow_grppre,findmefollow_grplist,findmefollow_annmsg_id,findmefollow_postdest,findmefollow_dring,findmefollow_needsconf,findmefollow_remotealert_id,findmefollow_toolate_id,findmefollow_ringing,findmefollow_pre_ring,findmefollow_voicemail,findmefollow_calendar_id,findmefollow_calendar_match,findmefollow_changecid,findmefollow_fixedcid,findmefollow_enabled,languages_language,voicemail_enable,voicemail_vmpwd,voicemail_email,voicemail_pager,voicemail_options,voicemail_same_exten,disable_star_voicemail,vmx_unavail_enabled,vmx_busy_enabled,vmx_temp_enabled,vmx_play_instructions,vmx_option_0_number,vmx_option_1_number,vmx_option_2_number
${ext},,"${name}",novm,0,,,,,,,,,,,default,${ext},pjsip,PJSIP/${ext},fixed,${ext},"${name}",,,disabled,dontcare,dontcare,dontcare,dontcare,disabled,10,disabled,enabled,${ext},3,,,,,,,,,,,,,,,,,,,,,,,,,,,"${name} <${ext}>",,,,,,,,,,,,,,,,,,,,,,,,yes,yes,from-internal,,0,yes,rfc4733,yes,no,,1,7200,sdes,yes,yes,,60,auto,,60,yes,yes,yes,yes,0,0,${password},yes,pai,chan_pjsip,yes,90,0.0.0.0-tls,yes,ENABLED,ringallv2-prim,20,,${ext},,"ext-local,${ext},dest",,,,,Ring,7,novm,,yes,default,,,en_GB,,,,,,,,,,,,,,
EOF

echo "Now bulk import ${ext}.csv into FreePBX and _securely_ send ${ext}.png to the employee"

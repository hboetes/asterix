# asterix
Scripts I wrote to help with asterix

Most interesting is the voipbl script which works together with fail2ban, https://voipbl.org and two other blacklists after which the number of attempts at my freepbx installation is less than 1 per day.

You'll have to add `-I INPUT 1 -m set --match-set voipbl src -j DROP` to the advanced section of the freepbx firewall settings, like this:
![image](https://user-images.githubusercontent.com/2285225/137595541-969a7556-dba4-42a0-85b9-b31248ac770a.png)

After which anything in the `voipbl` table will be blocked.

Install the script like this:

``` shell
sudo wget -o /usr/local/sbin/voipbl https://raw.githubusercontent.com/hboetes/asterix/master/voipbl
sudo chmod 744 /usr/local/sbin/voipbl
```

Then run my script to populate the table.

Also set up a cronjob for root to keep it up to date. Something like this:

``` shell
echo "0 */4 * * * /usr/local/sbin/voipbl" | sudo crontab
```

# Automated callture

These scripts put in place the number phone of the person entering the shift. 
  - tasks.yaml: playbook to be launched from ansible tower. It just launches the callture_rota_change.sh script
  - callture_rota_change.sh: Connects to Rotacloud API to get the person taking over the shift and his number phone, then launches callture.py with the number phone as parameter
  - callture.py: uses selenium and chromedriver to change the number of the person oncall on callture website


## Install dependencies
```
#RHEL 
Download chromedriver binary from official website
sudo mv chromedriver /usr/bin/chromedriver
sudo chown root:root /usr/bin/chromedriver
sudo chmod +x /usr/bin/chromedriver
yum install  xorg-x11-server-Xorg.x86_64 xorg-x11-xauth.x86_64 chromium.x86_64 chromedriver.x86_64 python3-pip
pip3 install selenium

#UBUNTU: sudo apt-get install chromium-chromedriver python-selenium python3-selenium 
cd /root (or create a user for this)
git clone https://github.com/crossvale-inc/msp-ocp.git
```

## Add cronjonb / ansible tower job

```
#UBUNTU
# Run at the beggining of the shift at 06:00, 14:00 and 22:00 everyday
0 6,14,22 * * * /root/msp-ocp/callture/callture_rota_change.sh
```
<img width="1215" alt="Screenshot 2021-01-25 at 19 40 45" src="https://user-images.githubusercontent.com/9881318/105750585-39152000-5f45-11eb-8492-f86d087be8d3.png">


## Set Madrid timezone
```
UBUNTU: timedatectl set-timezone "Europe/Madrid"
```

## Configure postfix service (ubuntu)

### Install software
```
UBUNTU: apt-get update && apt-get install postfix mailutils
RHEL: sudo yum install mailx
```

### Configure gmail authentication
```
vi /etc/postfix/sasl_passwd
[smtp.gmail.com]:587    username@gmail.com:password
``` 
```
chmod 600 /etc/postfix/sasl_passwd
```

### Configure postfix
```
vi /etc/postfix/main.cf
relayhost = [smtp.gmail.com]:587
smtp_use_tls = yes
smtp_sasl_auth_enable = yes
smtp_sasl_security_options =
smtp_sasl_password_maps = hash:/etc/postfix/sasl_passwd
smtp_tls_CAfile = /etc/ssl/certs/ca-certificates.crt
```
```
postmap /etc/postfix/sasl_passwd
```
```
systemctl enable postfix.service
systemctl restart postfix.service
```
[Enable less secure apps in gmail](https://support.google.com/accounts/answer/6010255)


# IMPORTANT
The script uses the secondary email field at rotacloud user profile, which can be a personal phone number or the one provided with the terminal. Make sure to introduce the correct prefix (for Spain use 01134). The script will fail if it doesn't find a secondary number phone set in rotacloud user profile.

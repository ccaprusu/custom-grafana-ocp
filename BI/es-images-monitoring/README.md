# Monitoring ES and Images

At the moment OCP 3.11 doesn't have any way to monitor this resources from the panel, and alert if users are generating bigger than desired images and containers. So that we have to collect the data with our own scripts and merge it in a visual format. 

# The code

This application is composed by 3 pieces:
- Bash script to gather docker data in each node.
- Python script that creates the excel file with tables and graphs.
- Ansible playbook that ensures each host has the necessary tools, scripts, gathers and process the data and sends the report by mail.

You can find the 3 pieces here:
https://github.com/crossvale-inc/msp-ocp/tree/master/BI/scripts

# How to install

All the steps install the monitoring are to be done in the bastion host, where at least ansible must be installed.

## Playbook
The ansible playbook needs a cronjob to execute the report periodically. We have decided to have a weekly report on monday mornings, so the client has visibility of this kind of work. That's why the playbook has been called "weekly.yaml". It was intended to follow BI naming convention about the tasks to be executed in that time. However we can change this to crossvale_tasks.yaml.


```bash
# weekly report for ephemeral-storage and images
1 10 * * 1 /usr/bin/ansible-playbook --inventory=/root/openshift/ocp/chn-ocdev/chn-ocdev.hosts /root/openshift/ocp/playbooks/weekly.yml
```

The playbook makes sure that our scripts directory is present, synchronises the script, checks that jq is installed, deletes the generated files in the previous run, executes the script and fetches the data, all of this per node.

Then it will execute a few local tasks in order to create the excel file, such assembling all the node data files into one big file and adding the headers that will show in the excel file columns. It will run the python script binary, which will now we will see how is created. 

The last playbook task is to send the excel file by mail. 

## Python binary

We will need the "ephemeral_storage_data_to_excel" placed into  /usr/local/bin/, but first a pyenv and some packages need to be installed.


```bash
yum groupinstall "Development Tools"
yum install -y xz-devel zlib-devel bzip2-devel openssl-devel libffi-devel
```

### Clone pyenv repositories
```bash
git clone https://github.com/yyuu/pyenv.git ~/.pyenv
git clone https://github.com/yyuu/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv
```

### Add to .bashrc 
```bash
[root@chn-oc-bastion ~]# vi .bashrc
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"

# Enable shims and autocompletion for pyenv.
eval "$(pyenv init -)"
# Load pyenv-virtualenv automatically by adding
# # the following to ~/.zshrc:
#
eval "$(pyenv virtualenv-init -)"
```

### Create a new python virtual environment
```bash
env PYTHON_CONFIGURE_OPTS="--enable-shared" pyenv install 3.8.1
pyenv virtualenv 3.8.1 bi
pyenv activate bi

pip install --upgrade pip
```

### Place the script and python requirements into a directory
```bash
# mkdir ephemeral-build
(bi) [root@chn-oc-bastion ~]# mkdir ephemeral-build
(bi) [root@chn-oc-bastion ~]# cd ephemeral-build/

# create requirements.txt
(bi) [root@chn-oc-bastion ephemeral-build]# vi requirements.txt
altgraph==0.17
et-xmlfile==1.0.1
jdcal==1.4.1
numpy==1.18.1
openpyxl==3.0.3
pandas==1.0.1
PyInstaller==3.6
python-dateutil==2.8.1
pytz==2019.3
six==1.14.0
XlsxWriter==1.2.8

(bi) [root@chn-oc-bastion ephemeral-build]# pip install -r requirements.txt

# Create the script with the code from github repo:
# https://github.com/crossvale-inc/msp-ocp/blob/master/BI/scripts/ephemeral_storage_data_to_excel.py
(bi) [root@chn-oc-bastion ephemeral-build]# vi ephemeral_storage_data_to_excel.py                               
```

### Generate the binary with pyinstaller
```bash
pyinstaller --onefile ephemeral_storage_data_to_excel.py
```

### Place the binary into /usr/local/bin/
```bash
mv dist/ephemeral_storage_data_to_excel  /usr/local/bin/
```

# END

NOTE: Make sure to uncomment proxy environment variables from the playbook if you are in INHAS or NAHAS bastions.

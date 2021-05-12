#!/bin/bash
#dirname="$(dirname "$0")"
dirname="$PWD"
echo "$dirname"

git clone https://gitlab.cee.redhat.com/gss-tools/rh-internal-citellus.git
git clone https://github.com/citellusorg/citellus.git
git clone https://gitlab.cee.redhat.com/tam/ocp-pssa.git

cd $dirname/citellus/citellusclient/locale/en/LC_MESSAGES/
ln -s $dirname/rh-internal-citellus/citellus.mo
ln -s $dirname/rh-internal-citellus/citellus.po
cd $dirname/citellus/citellusclient/
ln -s $dirname/rh-internal-citellus/citellus.conf
cd $dirname/citellus/citellusclient/plugins/
ln -s $dirname/rh-internal-citellus/overrides.json


cd $dirname/citellus/citellusclient/plugins/
# Regular but Faraday folders
for folder in $(find $dirname/rh-internal-citellus/plugins/ -maxdepth 1 -type d ! -name 'faraday'); do
    foldertarget=$(basename $folder)
    if [ "$foldertarget" != "plugins" ]; then
        echo "linking $folder"
        ln -s $folder $foldertarget/rhinternal
    fi
done

# Faraday Folders
for folder in $(find $dirname/rh-internal-citellus/plugins/ -maxdepth 1 -type d -name 'faraday'); do
    foldertarget=$(basename $folder)
    if [ "$foldertarget" != "plugins" ]; then
        echo "linking $folder"
        ln -s $folder/positive $foldertarget/positive/rhinternal
        ln -s $folder/negative $foldertarget/negative/rhinternal
    fi
done

cd $dirname

# Set CITELLUS_BASE for ocp-pssa scripts
sed -i "s|\$HOME/git|$dirname|g" $dirname/ocp-pssa/scripts/env_topology.sh

# do some dirty stuff we currently need to do - some time we should get rid of it
cp ./ocp-pssa/tools/citellus/citellusclient/common.d/* ./citellus/citellusclient/common.d
cd ..


echo "Installation finished you may now run citellus"


# Collection of Scripts to support the PSSA analysis

This folder contains a collection of small, quick and dirty scripts to assemble the data to derive conclusions per topic of the ocp-pssa.

These scripts will not take any conclusion for you. They pull the data you might need to base you conclusion on from the huge bunch of data collected by the playbook.
By intend they pull the data from all nodes where this data is expected to be available on. This might be more than you need, but it gives you the chance to spot unexpected differences.

## How to setup

- clone git repos:
   - `https://gitlab.cee.redhat.com/dmoessne/ocp-pssa`
   - `https://github.com/citellusorg/citellus.git`
   - `https://gitlab.cee.redhat.com/gss-tools/rh-internal-citellus.git`
- link `rh-internal-citellus` into `citellus` following the instructions to be found in `rh-internal-citellus`
- finally adjust `ocp-pssa/scripts/env_topology.sh` `CITELLUS_BASE="$HOME/git/citellus"` to your location

or simply use `https://gitlab.cee.redhat.com/dmoessne/ocp-pssa/raw/master/tools/install_pssa_tooling.sh` 

## How to use

- place a file named `node.sh` the directory where `pssa-out.gz` is located
   - this file should contain `MASTERNODES`, `ETCDNODES`, `INFRANODES` and `NODES` meeting your topology. This, while it assumed that every node is listed in a single category only, e.g. master-nodes in `MASTERNODES` only, but not in `NODES`. 
   - to extract and prepare the data for analysis there are 2 options:
   - extract `pssa-out.gz` using `tar xvf pssa-out.gz` and
   - run `extract_master_sos-reports.sh` to explod the nodes sos-reports
   - or more simply launch `rh-internal-citellus/openshift-pssa-analysis.sh` from the directory where `pssa-out.gz` is located.
- check if settings in `env_topology.sh` are valid for the OCP release in scope
- launch the `check*.sh` scripts as required from the folder you have extrated `pssa-out.gz` into
- **stay sceptical on the results!** - the scripts are quick hacks and might not cover your case or the docs have changed meanwhile

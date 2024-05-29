# terraform

< Insert warning about bad practices>

Also of note, all passwords/domains and mac/ip addresses used in this have been changed.  They do not reflect my reality at all :D

It is also worth noting a lot of other best-practice shortcuts have been avoided as examples here.  For example, each server is explicitly laid out, as opposed to using templates.  This is more for the end user to follow along then a suggested best practice.

Also worth noting, just about everything in here has IPv6 hard-coded to off.  If you use it at home well, change the "update X" to "update *"

## Prereq/env layout

- The terraform master node needs ansible and terraform installed
- The ansible key should be placed in '~/.ssh/id_rsa_ansible' for the user this will run as
- The temples to build servers are not provides, but the kickstarts/unattended files are provided as part of the "ansible" repo under this user.  They are very basic templates, and you can use your own, just need the right user/keys defined

## Passwords used
- Ansible user: "ansible" password "password"
- Pi-hole admin password: "password"

## How to use (First use)
- Clone this repo to your terraform command node
- Run "terraform init" to setup the terraform stuffz
- Update providers.tf to reflect your world.
  - The first time you do this, all the data may not be avaliable (ie rndc keys).  Just leave it as is for now, and we will update as we go.
- Update vmware-variables.tf to reflect your world using the guidance of the pre-req section
- Update variable.tf to reflect your world
  - Hard-coded MAC addresses like I have are purely to make my UDM's client dashboard not lose its mind every month when I rebuild every server, they are 100% not needed.
    - This ia a terrible practice.  See above warning about terrible ideas used
  - All my machines are built to vSAN storage, if you do not have the same either update all other tf files, or just change the vsan storage definition to be what you want without renaming it. 
- Create a .password file which contains the ansible password for your template.  If you use the ones built as part of this setup, its 'password'
  - This is another TERRIBLE practice and done out of lazyness and an inability to use a hashi-vault before the hashi-vault is up
- Update the ansible/roles/create_proxy/squid.conf file to match your reality.
  - Note, this file is only used before gitlab comes online, so the fact its wide open is not so important
- Build the first node to confirm everything works
  - "terraform apply -target vsphere_virtual_machine.proxy"
  - Verify the ansible job ran without incident, that the node can connect to the internet, squid is accepting connections, etc.
- Update ansible/roles/create_pihole/defaults/main.yml and  ansible/roles/create_pihole/files/99-local.conf to reflect your reality
- Update ansible/roles/create_bind/files/* to reflect your reality
  - rndc.key is another example of a terrible practice
    - Use what you put in there to update your providers.tf
  - This sucks, I know, but all future DNS changes are dynamic so its a pay once, cry once situation
- Update ansible/roles/create_vault/defaults/main.yml to reflect your reality
  - This is another TERRIBLE no good very bad practice.  NEVER put a vault key into the clear like this
  - For real, don't do this.  Also DONT have a vault auto-unlock via cron at boot.  It's NOTHING but lazyness and defeats the purpose of having a vault at all.
### Add plays for non-recovered vault here... or create an example vault and add it to the playbook....
- Trigger the build upto and including vault
  - "terraform apply -target vsphere_virtual_machine.vault"
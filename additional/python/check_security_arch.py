import os
import jessentials
import jfolders
import jfiles
from check_home_folder_rights import check_home_folder_rights
from arch_checkupdates import arch_checkupdates



def get_additional_sources():
    # Check if yay is installed
    if (jfiles.does_file_exist("/usr/bin/yay")):
        # lines = jessentials.run_command("/usr/bin/yay -Q", False, True)
        # for line in lines:
        #     print(f"aurpackage: {line.split(" ")[0]}")
        print("yayinstalled")

def get_available_updates():
    lines = arch_checkupdates()
    for line in lines:
        print(f"upgradeablepackage: {line}")

def check_server_access():
    # Check for firewall
    if (jfiles.does_file_exist("/usr/sbin/ufw")):
        lines = jessentials.run_command("/usr/sbin/iptables -L", False, True)
        ufwUserFound = False
        for line in lines:
            if "ufw-user" in line:
                ufwUserFound = True
                break
        if not ufwUserFound:
            print("firewallinactive")
    # Check for firewalld
    elif (jfiles.does_file_exist("/usr/bin/firewalld")):
        lines = jessentials.run_command("/usr/bin/firewall-cmd --list-all", False, True)
        if (len(lines) > 1):
            pass
        else:
            print("firewallinactive")
    else:
        print("nofirewall")
    
    # Check for Xrdp
    lines = jessentials.run_command("/usr/bin/systemctl status xrdp", False, True)
    if (len(lines) > 1):
        print("xrdprunning")
    # Check for ssh:
    lines = jessentials.run_command("/usr/bin/systemctl status ssh", False, True)
    if (len(lines) > 1):
        print("sshrunning")
        lines = jessentials.run_command("/usr/bin/systemctl status fail2ban", False, True)
        if (len(lines) == 0):
            print("fail2bannotrunning")

if __name__ == "__main__":
    jessentials.ensure_root_privileges()
    get_additional_sources()
    get_available_updates()
    check_home_folder_rights(jessentials.get_value_from_arguments("home", ""))
    check_server_access()
    print("#!script ran successfully.")

#!/usr/bin/python3

#   arch-checkupdates: Safely print a list of pending updates.

import os
import jessentials

def arch_checkupdates():
    uid = os.getuid()
    chkupdates_db = f'/tmp/la-checkup-db-{uid}'

    if os.path.isfile(f'{chkupdates_db}/db.lck'):
        os.remove(f'{chkupdates_db}/db.lck')

    dbpath = jessentials.run_command('/usr/bin/pacman-conf DBPath', print_output=False, return_output=True)[0]
    if not os.path.exists(dbpath):
        dbpath = '/var/lib/pacman/'

    if not os.path.exists(chkupdates_db):
        os.makedirs(chkupdates_db)

    # Pacman needs already installed packages to perform a update check.
    if not os.path.exists(f'{chkupdates_db}/local'):
        os.symlink(f'{dbpath}/local', f'{chkupdates_db}/local', target_is_directory=True)

    # If pacman updates the system repository databases without a system upgrade, pacman executes an parital upgrade which could break your system.
    # Instead pacman updates the repository databases in the defined temp directory (checkupdates_db) and can perform a save update check without touching the real database.
    jessentials.run_command(f'/usr/bin/pacman -Sy --dbpath {chkupdates_db} --logfile /dev/null', print_output=False, return_output=False)

    updates = list()
    updates = jessentials.run_command(f'/usr/bin/pacman -Qu --dbpath {chkupdates_db}', print_output=False, return_output=True)
    return updates
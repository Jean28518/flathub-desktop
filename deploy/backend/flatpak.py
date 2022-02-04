from html import entities
from multiprocessing.dummy import current_process
from sre_parse import CATEGORIES

from defer import return_value
from importlib_metadata import version
import jessentials

import os

# Here is a reference to the flathub api: https://github.com/flathub/backend/blob/master/app/main.py
# You can acces it with https://flathub.org/api/v1/apps

APP_CATEGORIES = ["AudioVideo","Development","Education","Game","Graphics","Network","Office","Science","System","Utility"]

_installing = []
_removing = []

def is_flatpak_available():
    flatpak_lines = jessentials.run_command("flatpak --version", False, True)
    return flatpak_lines[0].startswith("Flatpak")

def get_installed_applications():
    flatpak_lines = jessentials.run_command("flatpak list --app", False, True)
    
    return_value = []

    for line in flatpak_lines:
        elements = line.split("\t")
        return_value.append(elements[1])
    return return_value
    

def is_application_installed(application_id):
    return jessentials.is_element_in_array(get_installed_applications(), application_id)

def install_application(application_id):
    _installing.append(application_id)
    jessentials.run_command("flatpak install -y --system --noninteractive %s" % application_id, True)
    _installing.remove(application_id)

def remove_application(application_id):
    _removing.append(application_id)
    jessentials.run_command("flatpak remove -y --noninteractive %s" % application_id, True)
    _removing.remove(application_id)

def start_application(application_id):
    os.system("flatpak run %s &" % application_id)
    # jessentials.run_command("flatpak run %s" % application_id, False)

all_available_applications = []
def get_all_available_applications():
    installed_applications = get_installed_applications()
    if len(all_available_applications) > 0:
        for entry in all_available_applications:
            entry["installed"] = jessentials.is_element_in_array(installed_applications, entry["id"])
            entry["installing"] = jessentials.is_element_in_array(_installing, entry["id"])
            entry["removing"] = jessentials.is_element_in_array(_removing, entry["id"])
        return all_available_applications

    table = jessentials.from_json(jessentials.run_command("curl -s https://flathub.org/api/v1/apps", False, True)[0])

    for entry in table:
        all_available_applications.append({
            "id": entry["flatpakAppId"],
            "name": entry["name"],
            "summary": entry["summary"],
            "iconUrl": entry["iconDesktopUrl"],
            "installed": jessentials.is_element_in_array(installed_applications, entry["flatpakAppId"]),
            "installing": jessentials.is_element_in_array(_installing, entry["flatpakAppId"]),
            "removing": jessentials.is_element_in_array(_removing, entry["flatpakAppId"]),
            "categories": []
        })

    # Categories:
    for category in APP_CATEGORIES:
        table = jessentials.from_json(jessentials.run_command("curl -s https://flathub.org/api/v1/apps/category/%s" % category, False, True)[0])
        apps_in_category = []
        for category_entry in table:
            apps_in_category.append(category_entry["flatpakAppId"])
        for entry in all_available_applications:
            if entry["id"] in apps_in_category:
                entry["categories"].append(category)
    
    # Popular Apps:
    popular_apps = jessentials.run_command("curl -s https://raw.githubusercontent.com/flathub/linux-store-frontend/master/scripts/update-popular-apps-inputlist", False, True)
    for entry in all_available_applications:
        if entry["id"] in popular_apps:
            entry["categories"].append("Popular")
            
    
    return all_available_applications

_installed_information_cache = {}
def get_information_about_applications(application_ids):
    all_available_applications = get_all_available_applications()
    return_value = []
    for application in all_available_applications:
        if jessentials.is_element_in_array(application_ids, application["id"]):
            return_value.append(application)
    
    installed_applications = get_installed_applications()
    print(installed_applications)
    for entry in return_value:
        if jessentials.is_element_in_array(installed_applications, entry["id"]):
            entry["installed"] = True
            if entry["id"] in _installed_information_cache :
                entry = _installed_information_cache[entry["id"]]
            else: 
                flatpak_info = jessentials.run_command("flatpak info %s" % entry["id"], False, True)
                for line in flatpak_info:
                    if line.startswith("Version:"):
                        entry["version"] = line.replace("Version: ", "")
                    if line.startswith("Installed:"):
                        entry["installation_size"] = line.replace("Installed: ", "")
                        entry["installation_size"] = entry["installation_size"].replace("?", " ")
                    if line.startswith("License"):
                        entry["license"] = line.replace("License: ", "")
                _installed_information_cache[entry["id"]] = entry
        else:
            entry["installed"] = False
        entry["installing"] = jessentials.is_element_in_array(_installing, entry["id"])
        entry["removing"] = jessentials.is_element_in_array(_removing, entry["id"])
    return return_value
    

def get_categories():
    return APP_CATEGORIES

# Removes unused apps and updates all apps
def maintain():
    jessentials.run_command("flatpak uninstall --unused --noninteractive")
    jessentials.run_command("flatpak update --noninteractive")

# GitHub repository: https://github.com/Jean28518/jtools-unix-python
# License: Apache License 2.0

import errno
import os
import subprocess
import sys
import shlex
import json

def ensure_root_privileges():
    if not is_script_running_as_root():
        fail("This script must run as root! Try adding sudo before your command.", errno.EACCES)

def is_script_running_as_root():
    return os.geteuid() == 0

def does_file_exist(file_path):
    return os.path.exists(file_path)

def replace_tilde_to_home(folder_path):
    return folder_path.replace("~", os.environ['HOME'])

# example for enviroment={'DEBIAN_FRONTEND': 'noninteractive'}
# if return_output==true: function returns a array of strings
def run_command(command, print_output=True, return_output=False, enviroment = {}):
    process = subprocess.Popen(shlex.split(command), stdout=subprocess.PIPE, env=enviroment)
    output_lines = [] # In this the output is saved line per line
    if print_output or return_output:
        while True:
            output = process.stdout.readline()
            output = output.decode("utf-8")
            if output == "" and process.poll() is not None:
                break
            if output:
                if print_output:
                    print(output.strip())
                if return_output:
                    output_lines.append(output.strip())
        if return_output:
            return output_lines
        else:
            return process.poll()
    else:
        process.communicate()
        return process.poll()

def get_arguments():
    return sys.argv

def get_value_from_arguments(value_key, default=None):
    args = get_arguments()
    for arg in args:
        if arg.startswith("--" + value_key + "="):
            if len(arg) <= len(value_key)+3: # if line: "value_key="
                return default
            return_value = arg[len(value_key)+3:]
            return return_value
    return default

## short code: -h   long code: --help
def is_argument_option_given(long_code="", short_code=""):
    args = get_arguments()
    for arg in args:
        if arg.startswith("-") and not arg.startswith("--") and not short_code=="": ## Short code
            if short_code in arg:
                return True
        if arg == "--" + long_code and not long_code == "": ## Long code
            return True
    return False

# TODO: Implement Errno
def fail(error_message="", errno=-1):
    if (error_message != ""):
        print(error_message)
    else:
        print("Script failed!")

    sys.exit()

def remove_duplicates(array = []):
    return_array = []
    for element in array:
        if not is_element_in_array(return_array, element):
            return_array.append(element)
    return return_array

def is_element_in_array(array, element):
    for e in array:
        if e == element:
            return True
    return False


def get_table_of_csv_file(file_path):
    if not does_file_exist(file_path):
        fail("Can't find file: " + file_path)
    csv_file = open(file_path, 'r')
    csv_reader = csv.reader(csv_file)
    csv_raw_table = []
    for csv_line in csv_reader:
        csv_raw_table.append(csv_line)
    return csv_raw_table


# Get's a table like this: [["City", "Distance"], ["Nuremberg", 35], ["Munich", 87,4]]
# Returns a table like this: [{"City": "Nuremberg", "Distance": 35} , {"City": "Munich", "Distance": 87,4}]
# Access: table[1]["City"] -> "Munich"
def get_accessible_table_of_raw_csv_table(csv_raw_table):
    return_table = []
    for i in range(1, len(csv_raw_table)):
        entry_line = {}
        for j in range(len(csv_raw_table[0])):
            entry_line[csv_raw_table[0][j]] = (csv_raw_table[i][j])
        return_table.append(entry_line)
    return return_table

def from_json(json_string):
    return json.loads(json_string)

def to_json(dict):
    return json.dumps(dict)
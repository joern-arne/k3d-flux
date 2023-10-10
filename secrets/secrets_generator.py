#!/usr/bin/env python3

import os, sys
import argparse
import re
import yaml, json
import subprocess
import random
import string



def load_config(filename):
    if not os.path.isfile(filename):
        print(f'File "{filename}" does not exist')
        sys.exit(1)

    with open(filename, 'r') as file:
        config = yaml.safe_load(file)
    
    secrets = config.get('secrets')
    if not secrets:
        secrets = []
    
    return config.get('vault'), secrets



def op_exists(vault, secret):
    print(secret.get('title')+' ', end='')
    s = subprocess.Popen(
        'op item get {title} --vault={vault}'.format(
            vault=vault,
            title=secret.get('title')
        ).split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    streamdata = s.communicate()[0]

    if s.returncode == 0:
        print(f'exists in {vault}')
        return True
    else:
        print(f'does not exist in {vault}')
        return False


def generate(value):
    '''
    Requires generator expression identified by !{...}

    First aspect must be lenght of the generated password.

    Further supported aspects:
        - letters
        - digits
        - specialchars
        - [+-%&] custom class definition

    Example
        !{20,letters,digits,specialchars,[+-=]}
    
    Returns a generated password
    '''
    result = re.match(r'!{(.*)}', value)
    if result:
        attributes = result.group(1).split(',')
        desired_lenght = int(attributes[0])
        aspects = attributes[1:]
        add_chars = ''
        for aspect in aspects:
            result = re.match(r'\[(.*)\]', aspect)
            if result:
                add_chars = result.group(1)

        selected_classes = ''
        if 'letters' in aspects:
            selected_classes += string.ascii_letters
        if 'digits' in aspects:
            selected_classes += string.digits
        if 'specialchars' in aspects:
            selected_classes += string.punctuation

        selected_classes += add_chars

        return ''.join((random.choice(selected_classes) for i in range(desired_lenght)))
    else:
        return value


def op_create(vault, secret):
    print(f'create {secret.get("title")} in {vault}')
    s = subprocess.Popen(
        'op item create --category=login --vault={vault} --title={title} {tags} {kv_pairs}'.format(
            vault=vault,
            title=secret.get('title'),
            kv_pairs='\n\t'.join(list(map(lambda v: f'{v[0]}={generate(v[1])}', secret.get('data').items()))),
            tags='--tags ' + ','.join(secret.get('tags')) if secret.get('tags') else ''
        ).split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    streamdata = s.communicate()[0]



def op_get_list(vault):
    s = subprocess.Popen(
        'op item list --vault {vault} --format=json'.format(
            vault=vault,
        ).split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    streamdata = s.communicate()[0]
    return json.loads(streamdata)



def op_delete(vault, secret):
    title = secret.get('title')
    print(f'remove {title} from {vault}')
    s = subprocess.Popen(
        'op item delete {title} --vault {vault}'.format(
            vault=vault,
            title=title
        ).split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    streamdata = s.communicate()[0]



def has_up_to_date_tags(secret, existing_secrets):
    '''
    returns: exists, up_to_date_tags
    '''
    title = secret.get('title')
    existing_titles = [item.get('title') for item in existing_secrets]

    exists = up_to_date_tags = None

    if title in existing_titles:
        should_tags = set(secret.get('tags', []))
        is_tags = set([existing_sec.get('tags', []) for existing_sec in existing_secrets if existing_sec.get('title')==title][0])
        if (should_tags!=is_tags):
            if len(should_tags - is_tags) > 0:
                print(f'{title} needs update because tag{"s" if len(should_tags - is_tags) > 1 else ""} {", ".join(should_tags - is_tags)} {"are" if len(should_tags - is_tags) > 1 else "is"} missing')
            else:
                print(f'{title} needs update because tag{"s" if len(should_tags - is_tags) > 1 else ""} {", ".join(is_tags - should_tags)} {"are" if len(should_tags - is_tags) > 1 else "is"} required to be deleted')
            exists = True
            up_to_date_tags = False
        else:
            exists = up_to_date_tags = True

    else:
        print(f'{title} is missing')
        exists = up_to_date_tags = False

    return exists, up_to_date_tags



def op_update(vault, secret):
    print(f'update {secret.get("title")} in {vault}')
    s = subprocess.Popen(
        'op item edit --vault={vault} {title} {tags} {kv_pairs}'.format(
            vault=vault,
            title=secret.get('title'),
            kv_pairs='\n\t'.join(list(map(lambda v: f'{v[0]}={generate(v[1])}', secret.get('data').items()))),
            tags='--tags ' + ','.join(secret.get('tags')) if secret.get('tags') else ''
        ).split(),
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE
    )
    streamdata = s.communicate()[0]



if __name__ == '__main__':

    parser = argparse.ArgumentParser(
        description='Secrets-File CRUD for a 1Password Vault via 1Password CLI',
        epilog='Author: Jörn Arne Göttig (github.com/joern-arne)'
    )
    parser.add_argument('filename',
        help='location of config file'
    )
    args = parser.parse_args()

    vault, secrets = load_config(args.filename)
    existing_secrets = op_get_list(vault)

    # add / update secrets
    for secret in secrets:
        exists, up_to_date_tags = has_up_to_date_tags(secret, existing_secrets)
        if not exists:
            op_create(vault, secret)
        elif not up_to_date_tags:
            op_update(vault, secret)

    # remove secrets from vault that are not defined in the config file
    for existing_secret in existing_secrets:
        if existing_secret.get('title') not in [item.get('title') for item in secrets]:
            op_delete(vault, existing_secret)

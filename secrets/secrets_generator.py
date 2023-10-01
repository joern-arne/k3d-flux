#!/usr/bin/env python3

import yaml, json
import subprocess

def load_config(location='secrets/k3d-dev.secrets.yaml'):
    with open(location, 'r') as file:
        config = yaml.safe_load(file)
    
    return config.get('vault'), config.get('secrets')



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
        print('exists')
        return True
    else:
        print('does not exist')
        return False



def op_create(vault, secret):
    print(secret.get('title'), 'create')
    
    s = subprocess.Popen(
        'op item create --category=login --vault={vault} --title={title} {kv_pairs}'.format(
            vault=vault,
            title=secret.get('title'),
            kv_pairs='\n\t'.join(list(map(lambda v: f'"{v[0]}={v[1]}"', secret.get('data').items())))
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
    pass

def op_clean(vault, secrets):
    
    titles = [item.get('title') for item in secrets]
    print(titles)

    contents = op_get_list(vault)
    
    for title in [item.get('title') for item in contents]:
        if title not in titles:

    

if __name__ == '__main__':

    vault, secrets = load_config()
    
    # for secret in secrets:
    #     if not op_exists(vault, secret):
    #         op_create(vault, secret)

    op_clean(vault, secrets)


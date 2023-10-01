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
        print(f'exists in {vault}')
        return True
    else:
        print(f'does not exist in {vault}')
        return False



def op_create(vault, secret):
    print(f'create {secret.get("title")} in {vault}')

    s = subprocess.Popen(
        'op item create --category=login --vault={vault} --title={title} {tags} {kv_pairs}'.format(
            vault=vault,
            title=secret.get('title'),
            kv_pairs='\n\t'.join(list(map(lambda v: f'"{v[0]}={v[1]}"', secret.get('data').items()))),
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



def op_delete(vault, title):
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



def op_clean(vault, secrets):
    titles = [item.get('title') for item in secrets]
    contents = op_get_list(vault)
    
    for title in [item.get('title') for item in contents]:
        if title not in titles:
            op_delete(vault, title)



if __name__ == '__main__':
    vault, secrets = load_config()
    for secret in secrets:
        if not op_exists(vault, secret):
            op_create(vault, secret)

    op_clean(vault, secrets)

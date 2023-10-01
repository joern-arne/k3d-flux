#!/usr/bin/env python3

import yaml
import json

RELATIVE_PATH = 'secrets'
COMMAND_TEMPLATE = '''
op item create --category=login
\t--vault={vault}
\t--title={title}
\t{kv_pairs}
'''

with open(f'{RELATIVE_PATH}/k3d-dev.secrets.yaml', 'r') as file:
    config = yaml.safe_load(file)

vault = config.get('vault')
secrets = config.get('secrets')

for secret in secrets:
    print(COMMAND_TEMPLATE.format(
        vault=vault,
        title=secret.get('title'),
        kv_pairs='\n\t'.join(list(map(lambda v: f'"{v[0]}={v[1]}"', secret.get('data').items())))
    ))
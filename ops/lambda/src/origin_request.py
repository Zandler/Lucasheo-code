import json
from urllib.parse import parse_qs


def handler(event, context):
    print(event)

    response = event

    print("DEBUG: response: {}".format(response))
    return response

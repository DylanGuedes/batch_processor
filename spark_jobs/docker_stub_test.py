import sys
import requests

DEFAULT_BATCH_PROCESSOR_URL = "http://batch-processor:4545"

if __name__ == '__main__':
    my_uuid = sys.argv[1]
    print("STUB UUID:", my_uuid)
    response = requests.get(DEFAULT_BATCH_PROCESSOR_URL +
                            '/api/retrieve_params', json={"job_id": my_uuid})
    used_params = response.json()
    print("USEd_PARAMS:", used_params)


import logging
import time
import os

log_path = '/data/history/archiver/Log/log-file-name.log'
os.makedirs(os.path.dirname(log_path), exist_ok=True)

logging.basicConfig(filename=log_path, level=logging.INFO, format='%(asctime)s %(message)s')

while True:
    logging.info('Application 1 log message')
    time.sleep(5)
